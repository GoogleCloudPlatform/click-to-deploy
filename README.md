# About

Source for Google Click to Deploy solutions listed on Google Cloud Marketplace.

# Disclaimer

This is not an officially supported Google product.

# :warning: About log4j Vulnerabilities

We are constantly working on updating the scripts used in this repository to use non-impacted versions of the OSS that are used here. So updates are constanly being made in this repository.

Below is the list of solutions, in this repo, currently affected by the log4j CVEs, or using a log4j version < 2.16

## Virtual Machines

| Solution | Notes |
| --- | --- |
| elasticsearch | Vulnerable |
| logstash | Vulnerable |
| magento | Vulnerable (uses elasticsearch) |
| sonarqube | Vulnerable (uses elasticsearch) |
| liferay | Vulnerable |

## Kubernetes Applications

| Solution | Notes |
| --- | --- |
| activemq | Uses log4j 1.x |
| elastic-gke-logging | Vulnerable |
| elasticsearch | Vulnerable |
| kafka | Uses log4j 1.x |
| magento |  Vulnerable (uses elasticsearch) |
| sonarqube | Vulnerable (uses elasticsearch) |
| zookeeper | Vulnerable (uses elasticsearch) |

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
gcloud beta builds worker-pools create gcb-workers-pool-e2 \
  --project=[PROJECT_ID] \
  --peered-network=projects/[NETWORK_PROJECT_NUMBER]/global/networks/default \
  --region=us-central1 \
  --worker-machine-type=e2-standard-2
```

Where:

*   `[PROJECT_ID]` is the GCP project ID where you want to create your custom worker pool.
*   `[NETWORK_PROJECT_NUMBER]` is the project number of the Cloud project that holds your VPC network.

For more information, see the
[gcloud beta builds worker-pools commands](https://cloud.google.com/sdk/gcloud/reference/beta/builds/worker-pools/).
