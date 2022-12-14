{{- define "gitea.public_protocol" -}}
{{- if .Values.enablePublicServiceAndIngress -}}
https
{{- else -}}
http
{{- end -}}
{{- end -}}

{{- define "gitea.default_domain" -}}
{{- if .Values.gitea.domainName -}}
{{ .Values.gitea.domainName }}
{{- else -}}
{{- printf "%s-gitea-svc.%s.svc.cluster.local" .Release.Name .Release.Namespace -}}
{{- end -}}
{{- end -}}
