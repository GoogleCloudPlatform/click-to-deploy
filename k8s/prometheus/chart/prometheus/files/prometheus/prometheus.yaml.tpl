"alerting":
  "alertmanagers":
  - "kubernetes_sd_configs":
    - "namespaces":
        "names":
        - "default"
      "role": "endpoints"
    "path_prefix": "/"
    "relabel_configs":
    - "action": "keep"
      "regex": "default;alertmanager"
      "source_labels":
      - "__meta_kubernetes_namespace"
      - "__meta_kubernetes_service_label_k8s_app"
    - "action": "keep"
      "regex": "http"
      "source_labels":
      - "__meta_kubernetes_endpoint_port_name"
    "scheme": "http"
    "timeout": "10s"
"global":
  "scrape_interval": "15s"
"rule_files":
- "/etc/config/rules.yaml"
- "/etc/config/alerts.yaml"
"scrape_configs":
- "job_name": "kubernetes-service-endpoints"
  "kubernetes_sd_configs":
  - "role": "endpoints"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_service_label_(.+)"
  - "action": "keep"
    "regex": true
    "source_labels":
    - "__meta_kubernetes_service_annotation_prometheus_io_scrape"
  - "action": "replace"
    "regex": "(.+)"
    "source_labels":
    - "__meta_kubernetes_service_annotation_prometheus_io_path"
    "target_label": "__metrics_path__"
  - "action": "replace"
    "regex": "(https?)"
    "source_labels":
    - "__meta_kubernetes_service_annotation_prometheus_io_scheme"
    "target_label": "__scheme__"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?;(\\d+)"
    "replacement": "$1:$2"
    "source_labels":
    - "__address__"
    - "__meta_kubernetes_service_annotation_prometheus_io_port"
    "target_label": "__address__"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_namespace"
    "target_label": "namespace"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "pod"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "instance"
- "job_name": "kubernetes-services"
  "kubernetes_sd_configs":
  - "role": "service"
  "metrics_path": "/probe"
  "params":
    "module":
    - "http_2xx"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_service_label_(.+)"
  - "source_labels":
    - "__address__"
    "target_label": "__param_target"
  - "replacement": "blackbox"
    "target_label": "__address__"
  - "source_labels":
    - "__param_target"
    "target_label": "instance"
  - "action": "keep"
    "regex": true
    "source_labels":
    - "__meta_kubernetes_service_annotation_prometheus_io_probe"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_namespace"
    "target_label": "namespace"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "pod"
- "job_name": "kubernetes-pods"
  "kubernetes_sd_configs":
  - "role": "pod"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_pod_label_(.+)"
  - "action": "keep"
    "regex": true
    "source_labels":
    - "__meta_kubernetes_pod_annotation_prometheus_io_scrape"
  - "action": "replace"
    "regex": "(.+)"
    "source_labels":
    - "__meta_kubernetes_pod_annotation_prometheus_io_path"
    "target_label": "__metrics_path__"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?;(\\d+)"
    "replacement": "$1:$2"
    "source_labels":
    - "__address__"
    - "__meta_kubernetes_pod_annotation_prometheus_io_port"
    "target_label": "__address__"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_namespace"
    "target_label": "namespace"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "pod"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "instance"
- "job_name": "alertmanager"
  "kubernetes_sd_configs":
  - "role": "endpoints"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_service_label_(.+)"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?"
    "replacement": "$1:9093"
    "source_labels":
    - "__address__"
    "target_label": "__address__"
  - "action": "keep"
    "regex": "default;alertmanager"
    "source_labels":
    - "__meta_kubernetes_namespace"
    - "__meta_kubernetes_service_label_k8s_app"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_namespace"
    "target_label": "namespace"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "pod"
- "job_name": "cadvisor"
  "kubernetes_sd_configs":
  - "role": "node"
  "metric_relabel_configs":
  - "action": "drop"
    "regex": "^$"
    "source_labels":
    - "namespace"
  - "action": "drop"
    "regex": "^$"
    "source_labels":
    - "pod_name"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_node_label_(.+)"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?"
    "replacement": "$1:10255"
    "source_labels":
    - "__address__"
    "target_label": "__address__"
  - "replacement": "/metrics/cadvisor"
    "target_label": "__metrics_path__"
- "bearer_token_file": "/var/run/secrets/kubernetes.io/serviceaccount/token"
  "job_name": "apiserver"
  "kubernetes_sd_configs":
  - "role": "endpoints"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_service_label_(.+)"
  - "action": "keep"
    "regex": "default;kubernetes"
    "source_labels":
    - "__meta_kubernetes_namespace"
    - "__meta_kubernetes_service_name"
  - "action": "keep"
    "regex": "https"
    "source_labels":
    - "__meta_kubernetes_endpoint_port_name"
  "scheme": "https"
  "tls_config":
    "ca_file": "/var/run/secrets/kubernetes.io/serviceaccount/ca.crt"
    "insecure_skip_verify": true
- "job_name": "kube-dns"
  "kubernetes_sd_configs":
  - "role": "endpoints"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_service_label_(.+)"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?"
    "replacement": "$1:10054"
    "source_labels":
    - "__address__"
    "target_label": "__address__"
  - "action": "keep"
    "regex": "kube-system;kube-dns"
    "source_labels":
    - "__meta_kubernetes_namespace"
    - "__meta_kubernetes_service_name"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_namespace"
    "target_label": "namespace"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "pod"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "instance"
- "job_name": "kube-state-metrics"
  "kubernetes_sd_configs":
  - "role": "service"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_service_label_(.+)"
  - "action": "keep"
    "regex": "{{ .Release.Namespace }};kube-state-metrics"
    "source_labels":
    - "__meta_kubernetes_namespace"
    - "__meta_kubernetes_service_label_k8s_app"
- "job_name": "kubelet"
  "kubernetes_sd_configs":
  - "role": "node"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_node_label_(.+)"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?"
    "replacement": "$1:10255"
    "source_labels":
    - "__address__"
    "target_label": "__address__"
- "job_name": "node-exporter"
  "kubernetes_sd_configs":
  - "role": "pod"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_pod_label_(.+)"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?"
    "replacement": "$1:9100"
    "source_labels":
    - "__address__"
    "target_label": "__address__"
  - "action": "keep"
    "regex": "default;node-exporter"
    "source_labels":
    - "__meta_kubernetes_namespace"
    - "__meta_kubernetes_pod_label_k8s_app"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_namespace"
    "target_label": "namespace"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "pod"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_node_name"
    "target_label": "instance"
- "job_name": "prometheus"
  "kubernetes_sd_configs":
  - "role": "pod"
  "relabel_configs":
  - "action": "labelmap"
    "regex": "__meta_kubernetes_pod_label_(.+)"
  - "action": "replace"
    "regex": "([^:]+)(?::\\d+)?"
    "replacement": "$1:9090"
    "source_labels":
    - "__address__"
    "target_label": "__address__"
  - "action": "keep"
    "regex": "default;prometheus"
    "source_labels":
    - "__meta_kubernetes_namespace"
    - "__meta_kubernetes_pod_label_k8s_app"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_namespace"
    "target_label": "namespace"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "pod"
  - "action": "replace"
    "source_labels":
    - "__meta_kubernetes_pod_name"
    "target_label": "instance"
