{{- define "prometheus_operator.DeploymentName" -}}
{{- printf "%s-prometheus-operator" .Release.Name | trunc 63 -}}
{{- end -}}

{{- define "initContainerWaitForCRDsDeploy" -}}
- command:
  - "/bin/bash"
  - "-ec"
  - |
    timeout 120 bash -c '
    until kubectl get crd \
            alertmanagers.monitoring.coreos.com \
            podmonitors.monitoring.coreos.com \
            prometheuses.monitoring.coreos.com \
            prometheusrules.monitoring.coreos.com \
            servicemonitors.monitoring.coreos.com;
      do echo "Waiting for Prometheus CRDs created"; sleep 5;
    done'
  name: wait-for-crds-created
  image: {{ .Values.deployerHelm.image }}
{{- end -}}
