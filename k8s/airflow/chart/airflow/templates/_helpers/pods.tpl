{{/*
Define the image configs for airflow containers
*/}}
{{- define "airflow.image" }}
image: {{ .Values.airflow.image.repo }}:{{ .Values.airflow.image.tag }}
imagePullPolicy: IfNotPresent
securityContext:
  runAsUser: 50000
  runAsGroup: 0
{{- end }}

{{/*
Define the command/entrypoint configs for airflow containers
*/}}
{{- define "airflow.command" }}
- "/usr/bin/dumb-init"
- "--"
- "/entrypoint"
{{- end }}

{{/*
Define an init-container which checks the DB status
EXAMPLE USAGE: {{ include "airflow.init_container.check_db" (dict "Release" .Release "Values" .Values "volumeMounts" $volumeMounts) }}
*/}}
{{- define "airflow.init_container.check_db" }}
- name: check-db
  {{- include "airflow.image" . | indent 2 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- include "airflow.env" . | indent 4 }}
  command:
    {{- include "airflow.command" . | indent 4 }}
  args:
    - "db"
    - "check"
  volumeMounts:
    {{- include "airflow.volumeMounts" . | indent 4 }}
{{- end }}

{{/*
Define an init-container which waits for DB migrations
EXAMPLE USAGE: {{ include "airflow.init_container.wait_for_db_migrations" (dict "Release" .Release "Values" .Values "volumeMounts" $volumeMounts) }}
*/}}
{{- define "airflow.init_container.wait_for_db_migrations" }}
- name: wait-for-db-migrations
  {{- include "airflow.image" . | indent 2 }}
  envFrom:
    {{- include "airflow.envFrom" . | indent 4 }}
  env:
    {{- include "airflow.env" . | indent 4 }}
  command:
    {{- include "airflow.command" . | indent 4 }}
  args:
    - "db"
    - "check-migrations"
    - "-t"
    - "60"
  volumeMounts:
    {{- include "airflow.volumeMounts" . | indent 4 }}
{{- end }}

{{- define "airflow.volumeMounts" }}
- name: dags-logs-data
  mountPath: /opt/airflow/dags
  subPath: dags
- name: dags-logs-data
  mountPath: /opt/airflow/logs
  subPath: logs
{{- end }}

{{- define "airflow.volumes" }}
- name: dags-logs-data
  persistentVolumeClaim:
    claimName: {{ .Release.Name }}-nfs-dags-logs
{{- end }}

{{/*
The list of `envFrom` for web/scheduler/worker Pods
*/}}
{{- define "airflow.envFrom" }}
- secretRef:
    name: {{ .Release.Name }}-config-envs
{{- end }}

{{/*
The list of `env` for web/scheduler/worker Pods
EXAMPLE USAGE: {{ include "airflow.env" (dict "Release" .Release "Values" .Values "CONNECTION_CHECK_MAX_COUNT" "0") }}
*/}}
{{- define "airflow.env" }}
- name: DATABASE_HOST
  value: {{ .Release.Name }}-postgresql-svc
- name: CONNECTION_CHECK_MAX_COUNT
  {{- if .CONNECTION_CHECK_MAX_COUNT }}
  value: {{ .CONNECTION_CHECK_MAX_COUNT | quote }}
  {{- else }}
  value: "0"
  {{- end }}
{{- end }}
