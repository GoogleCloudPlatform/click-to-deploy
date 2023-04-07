{{- define "prometheus.alertmanagerName" -}}
{{- .Release.Name | trunc 14 -}}
{{- end -}}

{{- define "prometheus.prometheusName" -}}
{{- .Release.Name | trunc 16 -}}
{{- end -}}

