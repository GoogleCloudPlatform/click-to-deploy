{{/*
Common labels
*/}}
{{- define "hydra.labels" -}}
"app.kubernetes.io/name": {{ .Release.Name }}
"app.kubernetes.io/version": {{ .Chart.AppVersion | quote }}
"app.kubernetes.io/managed-by": {{ .Release.Service | quote }}
{{- end -}}

{{/*
Generate the dsn value
*/}}
{{- define "hydra.dsn" -}}
postgres://{{- .Values.postgresql.user }}:{{- .Values.postgresql.password }}@{{ .Release.Name }}-postgresql-svc:5432/{{- .Values.postgresql.postgresDatabase }}?sslmode=disable
{{- end -}}

{{/*
Generate the configmap data, redacting secrets
*/}}
{{- define "hydra.configmap" -}}
{{- $config := .Values.hydra.config -}}
{{- toYaml $config -}}
{{- end -}}
