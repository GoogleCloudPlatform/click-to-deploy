# Prometheus addon

Prometheus is a monitoring addon. It consists of:

1.  **Prometheus** - the server for metrics.
1.  **Node Exporter** - monitoring agent for exposing per-node metrics.
1.  **Alert Manager** - a manager for alerts.
1.  **Grafana** - the monitoring UI.

### Installation on GKE

```
kubectl create clusterrolebinding i-am-root --clusterrole=cluster-admin --user={{USERNAME}}@google.com
kubectl apply -f .
kubectl delete clusterrolebinding i-am-root
```

### Verify your installation

1.  Verify that all pods for Prometheus deployments are healthy:

    ```
    kubectl get pod -n kube-system -l k8s-app=prometheus
    kubectl get pod -n kube-system -l k8s-app=node-exporter
    kubectl get pod -n kube-system -l k8s-app=alertmanager
    kubectl get pod -n kube-system -l k8s-app=grafana
    ```

1.  Verify that Prometheus can scrape metrics from all targets:

    ```
    kubectl port-forward -n kube-system $(kubectl get pods -n kube-system -l \
        "k8s-app=prometheus" -o jsonpath="{.items[0].metadata.name}") 9090
    ```

    Go to [Prometheus targets page](http://localhost:9090/targets) and see if
    all targets are up.

1.  Verify that Grafana is configured with default dashboards and shows metrics
    from your cluster:

    ```
    kubectl port-forward -n kube-system $(kubectl get pods -n kube-system -l \
        "k8s-app=grafana" -o jsonpath="{.items[0].metadata.name}") 3000
    ```

    Retrieve an `admin` password for grafana from a secret:

    ```
    kubectl get secret -n kube-system grafana -o \
        jsonpath="{.data.admin-password}" | base64 --decode; echo
    ```

    Go to [Grafana home page](http://localhost:3000) and login as `admin` with
    retrieved password.

    Inspect the dashboards manually and see if the metrics are displayed.
