{{/*
Construct the base name for all resources in this chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "airflow.fullname" -}}
{{- printf "%s" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
The version of airflow being deployed.
- extracted from the image tag (only for images in airflow's official DockerHub repo)
- always in `XX.XX.XX` format (ignores any pre-release suffixes)
- empty if no version can be extracted
*/}}
{{- define "airflow.image.version" -}}
{{- if eq .Values.airflow.image.repository "apache/airflow" -}}
{{- regexFind `^[0-9]+\.[0-9]+\.[0-9]+` .Values.airflow.image.tag -}}
{{- end -}}
{{- end -}}

{{/*
Construct the `labels.app` for used by all resources in this chart.
*/}}
{{- define "airflow.labels.app" -}}
{{- printf "%s" .Chart.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the `labels.chart` for used by all resources in this chart.
*/}}
{{- define "airflow.labels.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Construct the name of the airflow ServiceAccount.
*/}}
{{- define "airflow.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
{{- .Values.serviceAccount.name | default (include "airflow.fullname" .) -}}
{{- else -}}
{{- .Values.serviceAccount.name | default "default" -}}
{{- end -}}
{{- end -}}

{{/*
The scheme (HTTP, HTTPS) used by the webserver
*/}}
{{- define "airflow.web.scheme" -}}
{{- if and (.Values.airflow.config.AIRFLOW__WEBSERVER__WEB_SERVER_SSL_CERT) (.Values.airflow.config.AIRFLOW__WEBSERVER__WEB_SERVER_SSL_KEY) -}}
HTTPS
{{- else -}}
HTTP
{{- end -}}
{{- end -}}

{{/*
The path containing DAG files
*/}}
{{- define "airflow.dags.path" -}}
{{- if .Values.dags.gitSync.enabled -}}
{{- printf "%s/repo/%s" (.Values.dags.path | trimSuffix "/") (.Values.dags.gitSync.repoSubPath | trimAll "/") -}}
{{- else -}}
{{- printf .Values.dags.path -}}
{{- end -}}
{{- end -}}

{{/*
Construct the `postgresql.fullname` of the postgresql sub-chat chart.
Used to discover the Service and Secret name created by the sub-chart.
*/}}
{{- define "airflow.postgresql.fullname" -}}
{{- if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default "postgresql" .Values.postgresql.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

