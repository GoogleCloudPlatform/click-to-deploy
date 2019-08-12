# WordPress with Cloud SQL

## Installation

1.  Complete [Prerequisites](https://github.com/GoogleCloudPlatform/k8s-config-connector#prerequisites) 
    from the Getting Started with Config Connector document.
1.  Run `make app/install` command.
1.  Copy a GCP service account to your namespace.
    
    ```shell
    kubectl get secret gcp-key --namespace=cnrm-system --export -o yaml \
      | kubectl apply --namespace=[NAMESPACE] -f -
    ```
    
    Where:
    
    * `[NAMESPACE` is your namespace name.
1.  Wait until a Cloud SQL instance is ready and enjoy it!


## TODO

1.  Fix `make app/verify` command.
2.  Address TODO comments.
