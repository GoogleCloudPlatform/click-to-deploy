{{- define "cert_manager.WebHookConfigMap" -}}
{{- printf "%s-crd-config-map" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "cert_manager.CRDsJob" -}}
{{- printf "%s-crd-job" .Release.Name | trunc 63 -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "cert-manager.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "webhook.fullname" -}}
{{- $trimmedName := printf "%s" (include "cert-manager.fullname" .) | trunc 55 | trimSuffix "-" -}}
{{- printf "%s-webhook" $trimmedName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "webhook.rootCACertificate" -}}
{{- $trimmedName := printf "%s" (include "cert-manager.fullname" .) | trunc 52 | trimSuffix "-" -}}
{{ printf "%s-webhook-ca" $trimmedName }}
{{- end -}}

{{- define "webhook.servingCertificate" -}}
{{- $trimmedName := printf "%s" (include "cert-manager.fullname" .) | trunc 51 | trimSuffix "-" -}}
{{ printf "%s-webhook-tls" $trimmedName }}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "cainjector.fullname" -}}
{{- $trimmedName := printf "%s" (include "cert-manager.fullname" .) | trunc 52 | trimSuffix "-" -}}
{{- printf "%s-cainjector" $trimmedName | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "initContainerWaitForCRDsDeploy" -}}
- command:
  - "/bin/bash"
  - "-ec"
  - |
    timeout 120 bash -c '
    until kubectl get crd certificaterequests.cert-manager.io \
                          certificates.cert-manager.io \
                          challenges.acme.cert-manager.io \
                          clusterissuers.cert-manager.io \
                          issuers.cert-manager.io \
                          orders.acme.cert-manager.io;
      do echo "Waiting for Cert Manager CRDs created"; sleep 5;
    done'
  name: wait-for-crds-created
  image: {{ .Values.deployer.image }}
{{- end -}}
