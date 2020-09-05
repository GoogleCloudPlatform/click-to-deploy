{{- define "istio_operator.CRDsConfigMap" -}}
{{- printf "%s-crd-config-map" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "istio_operator.CRDsJob" -}}
{{- printf "%s-crd-job" .Release.Name | trunc 63 -}}
{{- end -}}
