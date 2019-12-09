{{- define "nuclio.CRDsConfigMap" -}}
{{- printf "%s-crd-config-map" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "nuclio.CRDsJob" -}}
{{- printf "%s-crd-job" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "nuclio.controllerName" -}}
{{- printf "%s-controller" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "nuclio.registryCredentialsName" -}}
{{- if .Values.registry.secretName -}}
{{ .Values.registry.secretName }}
{{- else -}}
{{- printf "%s-registry-credentials" .Release.Name -}}
{{- end -}}
{{- end -}}

{{- define "nuclio.registryPushPullUrlName" -}}
{{- printf "%s-registry-url" .Release.Name -}}
{{- end -}}

{{- define "nuclio.dashboardName" -}}
{{- printf "%s-dashboard" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "initContainerWaitForCRDsDeploy" -}}
- command:
  - "/bin/bash"
  - "-ec"
  - |
    until kubectl get crd nucliofunctionevents.nuclio.io \
                          nucliofunctions.nuclio.io \
                          nuclioprojects.nuclio.io;
      do echo "Waiting for Nuclio CRDs created"; sleep 5;
    done
  name: wait-for-crds-created
  image: {{ .Values.deployerHelm.image }}
{{- end -}}
