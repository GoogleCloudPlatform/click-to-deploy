# Google Click to Deploy Kubernetes apps

## About

This directory hosts the source code of Google Click to Deploy Kubernetes apps
available through Google Cloud Platform Marketplace.

## Disclaimer

This is not an officially supported Google product.

## Cloud Build CI

This repository uses Cloud Build for continuous integration. The Cloud Build
configuration file for K8s apps is located at
[`../cloudbuild-k8s.yaml`](../cloudbuild-k8s.yaml).

### Manually run the build

Cloud Build can be triggered manually by running the following command from the
root directory of this repository:

```shell
export GCP_PROJECT_TO_RUN_CLOUD_BUILD=<>
export GKE_CLUSTER_NAME=<>
export GKE_CLUSTER_LOCATION=<e.g. us-central1>
export SOLUTION_NAME=<e.g. wordpress>

gcloud builds submit . \
  --config cloudbuild-k8s.yaml \
  --substitutions _CLUSTER_NAME=$GKE_CLUSTER_NAME,_CLUSTER_LOCATION=$GKE_CLUSTER_LOCATION,_SOLUTION_NAME=$SOLUTION_NAME \
  --project $GCP_PROJECT_TO_RUN_CLOUD_BUILD \
  --verbosity info
```

### Build steps

1.  Build `click-to-deploy` Docker image. The image contains the necessary tools
    required by the CI pipeline.
1.  Generate Cloud Build configuration for an application defined in
    `$_SOLUTION_NAME` variable. The configuration contains all required steps to
    test the application.
1.  Run additional Cloud Build instance using the generated configuration.
