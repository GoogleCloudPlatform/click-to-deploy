{{/*
Define Protocol based if the certificate has been provided or not
*/}}
{{- define "ingress.protocol" -}}
{{- if .Values.tls.base64EncodedCertificate -}}
    HTTPS
{{- else -}}
    HTTP
{{- end -}}
{{- end -}}
