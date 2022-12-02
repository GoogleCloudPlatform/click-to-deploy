{{- define "gitea.public_protocol" -}}
{{- if .Values.ingress.enabled -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "gitea.default_domain" -}}
{{- printf "%s-gitea-svc.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- end -}}
