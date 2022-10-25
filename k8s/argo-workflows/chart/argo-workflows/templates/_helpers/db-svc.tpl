{{- define "argoworkflows.db_svc" -}}
{{ tpl (.Values.argo_workflows.db.host) . }}
{{- end }}
