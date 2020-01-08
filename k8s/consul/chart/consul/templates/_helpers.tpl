{{/*
Compute the maximum number of unavailable replicas for the PodDisruptionBudget.
This defaults to (n/2)-1 where n is the number of members of the server cluster.
Special case of replica equaling 3 and allowing a minor disruption of 1 otherwise
use the integer value
Add a special case for replicas=1, where it should default to 0 as well.
*/}}
{{- define "consul.pdb.maxUnavailable" -}}
{{- if eq (int .Values.server.replicas) 1 -}}
{{ 0 }}
{{- else if .Values.server.disruptionBudget.maxUnavailable -}}
{{ .Values.server.disruptionBudget.maxUnavailable -}}
{{- else -}}
{{- if eq (int .Values.server.replicas) 3 -}}
{{- 1 -}}
{{- else -}}
{{- sub (div (int .Values.server.replicas) 2) 1 -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Define environment for gossipEncryption key if encryption is enabled
*/}}
{{- define "consul.gossipEncryption.env" -}}
{{- if .Values.global.gossipEncryption.CreateSecretWithKey -}}
- name: GOSSIP_KEY
  valueFrom:
    secretKeyRef:
      name: {{ .Release.Name }}-consul-gossip-key
      key: key
{{- end -}}
{{- end -}}

{{/*
Inject additional parameter to cmd if gossipEncryption is enabled
*/}}
{{ define "consul.gossipEncryption.cmd" }}
{{- if .Values.global.gossipEncryption.CreateSecretWithKey -}}
-encrypt="${GOSSIP_KEY}" \
{{ end }}
{{- end }}
