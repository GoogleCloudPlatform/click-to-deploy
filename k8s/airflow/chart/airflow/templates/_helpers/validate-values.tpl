{{/* Checks for `.Release.name` */}}
{{- if gt (len .Release.Name) 43 }}
  {{ required "The `.Release.name` must be less than 43 characters (due to the 63 character limit for names in Kubernetes)!" nil }}
{{- end }}

{{/* Checks for `dags.persistence` */}}
{{- if .Values.dags.persistence.enabled }}
  {{- if not (has .Values.dags.persistence.accessMode (list "ReadOnlyMany" "ReadWriteMany")) }}
  {{ required "The `dags.persistence.accessMode` must be one of: [ReadOnlyMany, ReadWriteMany]!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `dags.gitSync` */}}
{{- if .Values.dags.gitSync.enabled }}
  {{- if .Values.dags.persistence.enabled }}
  {{ required "If `dags.gitSync.enabled=true`, then `persistence.enabled` must be disabled!" nil }}
  {{- end }}
  {{- if not .Values.dags.gitSync.repo }}
  {{ required "If `dags.gitSync.enabled=true`, then `dags.gitSync.repo` must be non-empty!" nil }}
  {{- end }}
  {{- if and (.Values.dags.gitSync.sshSecret) (.Values.dags.gitSync.httpSecret) }}
  {{ required "At most, one of `dags.gitSync.sshSecret` and `dags.gitSync.httpSecret` can be defined!" nil }}
  {{- end }}
  {{- if and (.Values.dags.gitSync.repo | lower | hasPrefix "git@github.com") (not .Values.dags.gitSync.sshSecret) }}
  {{ required "You must define `dags.gitSync.sshSecret` when using GitHub with SSH for `dags.gitSync.repo`!" nil }}
  {{- end }}
{{- end }}

{{/* Checks for `ingress` */}}
{{- if .Values.ingress.enabled }}
  {{/* Checks for `ingress.apiVersion` */}}
  {{- if not (has .Values.ingress.apiVersion (list "networking.k8s.io/v1" "networking.k8s.io/v1beta1")) }}
  {{ required "The `ingress.apiVersion` must be one of: [networking.k8s.io/v1, networking.k8s.io/v1beta1]!" nil }}
  {{- end }}

  {{/* Checks for `ingress.web.path` */}}
  {{- if .Values.ingress.web.path }}
    {{- if not (.Values.ingress.web.path | hasPrefix "/") }}
    {{ required "The `ingress.web.path` should start with a '/'!" nil }}
    {{- end }}
    {{- if .Values.ingress.web.path | hasSuffix "/" }}
    {{ required "The `ingress.web.path` should NOT include a trailing '/'!" nil }}
    {{- end }}
  {{- end }}
{{- end }}

