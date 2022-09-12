{{/* vim: set filetype=mustache: */}}
{{/*

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}

{{/*
Ensure there is always a way to track down source of the deployment.
It is unlikely AppVersion will be missing, but we will fallback on the
chart's version in that case.
*/}}
{{- define "hydra.version" -}}
{{- if .Chart.AppVersion }}
{{- .Chart.AppVersion -}}
{{- else -}}
{{- printf "v%s" .Chart.Version -}}
{{- end -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "hydra.labels" -}}
"app.kubernetes.io/name": {{ .Release.Name }}
"app.kubernetes.io/version": {{ include "hydra.version" . | quote }}
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
