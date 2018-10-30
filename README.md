# About

Source for Google Click to Deploy solutions listed on Google Cloud Marketplace.

# Disclaimer

This is not an officially supported Google product.

# Git submodules

This repository uses [git submodule](https://git-scm.com/docs/git-submodule).
Please run following commands to receive newest version of used modules.

## Updating git submodules

You can use make to make sure submodules are populated with proper code.

```shell
make submodule/init # or make submodule/init-force
```

Alternatively, you can invoke these commands directly in shell, without `make`.

```shell
git submodule init
git submodule sync --recursive
git submodule update --recursive --init
```

# Cloud Build CI

This repository uses Cloud Build for continuous integration. The Cloud Build
configuration file is located at [`cloudbuild.yaml`](cloudbuild.yaml).

## Manually run the build

Cloud Build can be triggered manually by running the following command from the
root directory of this repository:

```shell
export GCP_PROJECT_TO_RUN_CLOUD_BUILD=<>
export GKE_CLUSTER_NAME=<>
export GKE_CLUSTER_LOCATION=<e.g. us-central1>
export GIT_COMMIT_SHA=<>

gcloud builds submit . \
  --config cloudbuild.yaml \
  --substitutions _CLUSTER_NAME=$GKE_CLUSTER_NAME,_CLUSTER_LOCATION=$GKE_CLUSTER_LOCATION,COMMIT_SHA=$GIT_COMMIT_SHA \
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
