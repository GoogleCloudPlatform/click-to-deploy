# About

Source for Google Click to Deploy solutions listed on Google Cloud Marketplace.

# Disclaimer

This is not an officially supported Google product.

# Cloud Build CI

This repository uses Cloud Build for continuous integration. Each type of application has its own configuration file.

For detailed information on each configuration, see the following documentations:

*   [Docker images](docker/README.md#cloud-build-ci)
*   [K8s applications](k8s/README.md#cloud-build-ci)
*   [VM applications](vm/README.md#cloud-build-ci)

## GCB custom worker pools

The Cloud Build configurations use Google Cloud Build (GCB) custom worker pools.

If you want to create a new worker pool, run the following command:

```shell
gcloud alpha builds worker-pools create gcb-workers-pool \
  --project=[PROJECT_ID] \
  --regions=us-central1,us-west1,us-east1,us-east-4 \
  --worker-count=2 \
  --worker-machine-type=n1-standard-1 \
  --worker-tag=gcb-worker \
  --worker-network-name=default \
  --worker-network-project=[PROJECT_ID] \
  --worker-network-subnet=default
```

Where:

*   `[PROJECT_ID]` is the GCP project ID where you want to create your custom worker pool.

If you want to update the number of workers in an existing pool, run the following command:

```shell
gcloud alpha builds worker-pools update gcb-workers-pool \
  --project=[PROJECT_ID] \
  --worker-count=4 \
```

For more information, see the
[gcloud alpha builds worker-pools commands](https://cloud.google.com/sdk/gcloud/reference/alpha/builds/worker-pools/).
