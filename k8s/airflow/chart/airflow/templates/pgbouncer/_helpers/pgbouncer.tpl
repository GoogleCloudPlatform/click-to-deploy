{{/*
Define the content of the `pgbouncer.ini` config file.
*/}}
{{- define "airflow.pgbouncer.pgbouncer.ini" }}
[databases]
{{- if .Values.postgresql.enabled }}
* = host={{ printf "%s.%s.svc.%s" (include "airflow.postgresql.fullname" .) (.Release.Namespace) (.Values.airflow.clusterDomain) }} port=5432
{{- else }}
* = host={{ .Values.externalDatabase.host }} port={{ .Values.externalDatabase.port }}
{{- end }}

[pgbouncer]
pool_mode = transaction
max_client_conn = {{ .Values.pgbouncer.maxClientConnections }}
default_pool_size =  {{ .Values.pgbouncer.poolSize }}
ignore_startup_parameters = extra_float_digits

listen_port = 6432
listen_addr = *

auth_type = {{ .Values.pgbouncer.authType }}
auth_file = /home/pgbouncer/users.txt

log_disconnections = {{ .Values.pgbouncer.logDisconnections }}
log_connections = {{ .Values.pgbouncer.logConnections }}

# locks will never be released when `pool_mode=transaction` (airflow initdb/upgradedb scripts create locks)
server_reset_query = SELECT pg_advisory_unlock_all()
server_reset_query_always = 1

## CLIENT TLS SETTINGS ##
client_tls_sslmode = {{ .Values.pgbouncer.clientSSL.mode }}
client_tls_ciphers = {{ .Values.pgbouncer.clientSSL.ciphers }}
{{- if .Values.pgbouncer.clientSSL.caFile.existingSecret }}
client_tls_ca_file = /home/pgbouncer/certs/client-ca.crt
{{- end }}
client_tls_key_file = /home/pgbouncer/certs/client.key
client_tls_cert_file = /home/pgbouncer/certs/client.crt

## SERVER TLS SETTINGS ##
server_tls_sslmode = {{ .Values.pgbouncer.serverSSL.mode }}
server_tls_ciphers = {{ .Values.pgbouncer.serverSSL.ciphers }}
{{- if .Values.pgbouncer.serverSSL.caFile.existingSecret }}
server_tls_ca_file = /home/pgbouncer/certs/server-ca.crt
{{- end }}
{{- if .Values.pgbouncer.serverSSL.keyFile.existingSecret }}
server_tls_key_file = /home/pgbouncer/certs/server.key
{{- end }}
{{- if .Values.pgbouncer.serverSSL.certFile.existingSecret }}
server_tls_cert_file = /home/pgbouncer/certs/server.crt
{{- end }}

{{- end }}

{{/*
Define the content of the `gen_auth_file.sh` sh script.
*/}}
{{- define "airflow.pgbouncer.gen_auth_file.sh" }}
#!/bin/sh -e

# DESCRIPTION:
# - updates the pgbouncer `auth_file` from environment variables
# - called in main pgbouncer container start-command so that `auth_file` is updated each restart,
#   for example, when the livenessProbe fails due to a DATABASE_PASSWORD secret update

# variables to increase clarity of pattern matching
ONE_QUOTE='"'
TWO_QUOTE='""'

# pgbouncer requires `"` to be escaped as `""`
ESCAPED_DATABASE_USER="${DATABASE_USER/$ONE_QUOTE/$TWO_QUOTE}"
ESCAPED_DATABASE_PASSWORD="${DATABASE_PASSWORD/$ONE_QUOTE/$TWO_QUOTE}"

# pgbouncer requires auth_file in format `"my-username" "my-password"`
echo \"$ESCAPED_DATABASE_USER\" \"$ESCAPED_DATABASE_PASSWORD\" > /home/pgbouncer/users.txt
echo "Successfully generated auth_file: /home/pgbouncer/users.txt"
{{- end }}
