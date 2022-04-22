{{/*
Construct the base name for all resources in this chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
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
{{- .Release.Name -}}
{{- end -}}

