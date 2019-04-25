# Cloud Build CI

This repository uses Cloud Build for continuous integration. The Cloud Build configuration file is located at [`cloudbuild.yaml`](cloudbuild.yaml).

## Manually run the build

Cloud Build can be triggered manually by running the following command
from the root directory of this repository:

```shell
export GCP_PROJECT_TO_RUN_CLOUD_BUILD=<>
export GKE_CLUSTER_NAME=<>
export GKE_CLUSTER_LOCATION=<e.g. us-central1>

gcloud builds submit . \
  --config cloudbuild.yaml \
  --substitutions _CLUSTER_NAME=$GKE_CLUSTER_NAME,_CLUSTER_LOCATION=$GKE_CLUSTER_LOCATION \
  --project $GCP_PROJECT_TO_RUN_CLOUD_BUILD \
  --verbosity info
```

## Cloud Build configuration generator

To make the `cloudbuild.yaml` configuration easier to maintain, a generator for
its contents was created.

1.  The generator uses Jinja2 templates, install it using `pip install jinja2`
    command.
1.  To regenerate the file, run the following command:

    ```shell
    ./cloudbuild-k8s-generator.py
    ```

1.  As a result, new content will be saved in the `cloudbuild.yaml` file.
