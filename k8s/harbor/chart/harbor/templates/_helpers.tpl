{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "harbor.name" -}}
{{- default "harbor" .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "harbor.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default "harbor" .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/* Helm required labels */}}
{{- define "harbor.labels" -}}
heritage: {{ .Release.Service }}
app.kubernetes.io/name: {{ .Release.Name }}
chart: {{ .Chart.Name }}
app.kubernetes.io/app: "{{ template "harbor.name" . }}"
{{- end -}}

{{/* matchLabels */}}
{{- define "harbor.matchLabels" -}}
app.kubernetes.io/name: {{ .Release.Name }}
app.kubernetes.io/app: "{{ template "harbor.name" . }}"
{{- end -}}

{{- define "harbor.autoGenCert" -}}
    {{- printf "true" -}}
{{- end -}}

{{- define "harbor.autoGenCertForIngress" -}}
  {{- if and (eq (include "harbor.autoGenCert" .) "true") (eq .Values.expose.type "ingress") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.autoGenCertForNginx" -}}
  {{- if and (eq (include "harbor.autoGenCert" .) "true") (ne .Values.expose.type "ingress") -}}
    {{- printf "true" -}}
  {{- else -}}
    {{- printf "false" -}}
  {{- end -}}
{{- end -}}

{{- define "harbor.database.host" -}}
    {{- template "harbor.database" . }}
{{- end -}}

{{- define "harbor.database.port" -}}
    {{- printf "%s" "5432" -}}
{{- end -}}

{{- define "harbor.database.username" -}}
    {{- printf "%s" "postgres" -}}
{{- end -}}

{{- define "harbor.database.rawPassword" -}}
    {{- .Values.database.password -}}
{{- end -}}

{{- define "harbor.database.escapedRawPassword" -}}
  {{- include "harbor.database.rawPassword" . | urlquery | replace "+" "%20" -}}
{{- end -}}

{{- define "harbor.database.encryptedPassword" -}}
  {{- include "harbor.database.rawPassword" . | b64enc | quote -}}
{{- end -}}

{{- define "harbor.database.coreDatabase" -}}
    {{- printf "%s" "registry" -}}
{{- end -}}

{{- define "harbor.database.notaryServerDatabase" -}}
    {{- printf "%s" "notaryserver" -}}
{{- end -}}

{{- define "harbor.database.notarySignerDatabase" -}}
    {{- printf "%s" "notarysigner" -}}
{{- end -}}

{{- define "harbor.database.sslmode" -}}
    {{- printf "%s" "disable" -}}
{{- end -}}

{{- define "harbor.database.notaryServer" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.escapedRawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notaryServerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.database.notarySigner" -}}
postgres://{{ template "harbor.database.username" . }}:{{ template "harbor.database.escapedRawPassword" . }}@{{ template "harbor.database.host" . }}:{{ template "harbor.database.port" . }}/{{ template "harbor.database.notarySignerDatabase" . }}?sslmode={{ template "harbor.database.sslmode" . }}
{{- end -}}

{{- define "harbor.redis.scheme" -}}
  {{- with .Values.redis }}
    {{- ternary "redis+sentinel" "redis"  (and (eq .type "external" ) (not (not .external.sentinelMasterSet))) }}
  {{- end }}
{{- end -}}

{{- define "harbor.redis.masterSet" -}}
  {{- with .Values.redis }}
    {{- ternary .external.sentinelMasterSet "" (eq "redis+sentinel" (include "harbor.redis.scheme" $)) }}
  {{- end }}
{{- end -}}

{{- define "harbor.redis.dbForRegistry" -}}
  {{- with .Values.redis }}
    {{- ternary "2" .external.registryDatabaseIndex (eq .type "internal") }}
  {{- end }}
{{- end -}}

{{- define "harbor.redis.dbForChartmuseum" -}}
  {{- with .Values.redis }}
    {{- ternary "3" .external.chartmuseumDatabaseIndex (eq .type "internal") }}
  {{- end }}
{{- end -}}

{{- define "harbor.portal" -}}
  {{- printf "%s-portal" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.core" -}}
  {{- printf "%s-core" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.redis" -}}
  {{- printf "%s-redis" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.jobservice" -}}
  {{- printf "%s-jobservice" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.registry" -}}
  {{- printf "%s-registry" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.registryCtl" -}}
  {{- printf "%s-registryctl" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.chartmuseum" -}}
  {{- printf "%s-chartmuseum" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.database" -}}
  {{- printf "%s-database" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.trivy" -}}
  {{- printf "%s-trivy" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.notary-server" -}}
  {{- printf "%s-notary-server" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.notary-signer" -}}
  {{- printf "%s-notary-signer" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.nginx" -}}
  {{- printf "%s-nginx" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.exporter" -}}
  {{- printf "%s-exporter" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.ingress" -}}
  {{- printf "%s-ingress" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.ingress-notary" -}}
  {{- printf "%s-ingress-notary" (include "harbor.fullname" .) -}}
{{- end -}}

{{- define "harbor.noProxy" -}}
  {{- printf "%s,%s,%s,%s,%s,%s,%s,%s,%s,%s,%s" (include "harbor.core" .) (include "harbor.jobservice" .) (include "harbor.database" .) (include "harbor.chartmuseum" .) (include "harbor.notary-server" .) (include "harbor.notary-signer" .) (include "harbor.registry" .) (include "harbor.portal" .) (include "harbor.trivy" .) (include "harbor.exporter" .) "127.0.0.1,localhost,.local,.internal" -}}
{{- end -}}

{{- define "harbor.caBundleVolume" -}}
- name: ca-bundle-certs
  secret:
    secretName: {{ .Values.caBundleSecretName }}
{{- end -}}

{{- define "harbor.caBundleVolumeMount" -}}
- name: ca-bundle-certs
  mountPath: /harbor_cust_cert/custom-ca.crt
  subPath: ca.crt
{{- end -}}

{{/* scheme for all components except notary because it only support http mode */}}
{{- define "harbor.component.scheme" -}}
    {{- printf "http" -}}
{{- end -}}

{{/* chartmuseum component container port */}}
{{- define "harbor.chartmuseum.containerPort" -}}
    {{- printf "9999" -}}
{{- end -}}

{{/* chartmuseum component service port */}}
{{- define "harbor.chartmuseum.servicePort" -}}
    {{- printf "80" -}}
{{- end -}}

{{/* core component container port */}}
{{- define "harbor.core.containerPort" -}}
    {{- printf "8080" -}}
{{- end -}}

{{/* jobservice component container port */}}
{{- define "harbor.jobservice.containerPort" -}}
    {{- printf "8080" -}}
{{- end -}}

{{/* jobservice component service port */}}
{{- define "harbor.jobservice.servicePort" -}}
    {{- printf "80" -}}
{{- end -}}


{{/* portal component service port */}}
{{- define "harbor.portal.servicePort" -}}
    {{- printf "80" -}}
{{- end -}}

{{/* registry component container port */}}
{{- define "harbor.registry.containerPort" -}}
    {{- printf "5000" -}}
{{- end -}}

{{/* registry component service port */}}
{{- define "harbor.registry.servicePort" -}}
    {{- printf "5000" -}}
{{- end -}}

{{/* registryctl component container port */}}
{{- define "harbor.registryctl.containerPort" -}}
    {{- printf "8080" -}}
{{- end -}}

{{/* registryctl component service port */}}
{{- define "harbor.registryctl.servicePort" -}}
    {{- printf "8080" -}}
{{- end -}}

{{/* trivy component container port */}}
{{- define "harbor.trivy.containerPort" -}}
    {{- printf "8080" -}}
{{- end -}}

{{/* trivy component service port */}}
{{- define "harbor.trivy.servicePort" -}}
    {{- printf "8080" -}}
{{- end -}}

{{- define "harbor.tlsCoreSecretForIngress" -}}
    {{- include "harbor.ingress" . -}}
{{- end -}}

{{- define "harbor.tlsNotarySecretForIngress" -}}
    {{- include "harbor.ingress" . -}}
{{- end -}}

{{- define "harbor.tlsSecretForNginx" -}}
    {{- include "harbor.nginx" . -}}
{{- end -}}

{{- define "harbor.metricsPortName" -}}
    {{- printf "http-metrics" -}}
{{- end -}}

{{/* Allow KubeVersion to be overridden. */}}
{{- define "harbor.ingress.kubeVersion" -}}
  {{- default .Capabilities.KubeVersion.Version .Values.expose.ingress.kubeVersionOverride -}}
{{- end -}}
