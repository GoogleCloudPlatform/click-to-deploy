{{- define "jaeger_operator.CRDsConfigMap" -}}
{{- printf "%s-crd-config-map" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "jaeger_operator.CRDsJob" -}}
{{- printf "%s-crd-job" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "jaeger_operator.DeploymentName" -}}
{{- printf "%s-jaeger-operator" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "initContainerWaitForCRDsDeploy" -}}
- command:
  - "/bin/bash"
  - "-ec"
  - |
    timeout 120 bash -c '
    until kubectl get crd jaegers.jaegertracing.io;
      do echo "Waiting for Jaegers CRDs created"; sleep 5;
    done'
  name: wait-for-crds-created
  image: {{ .Values.deployerHelm.image }}
{{- end -}}
