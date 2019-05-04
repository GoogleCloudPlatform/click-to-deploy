# Google Click to Deploy containers

## About

This directory hosts the source code for the Google Click to Deploy container images
available through Google Cloud Platform Marketplace.

## Disclaimer

This is not an officially supported Google product.

## Docker images

The source code for the Docker images is being migrated to this repository.
While the migration is in progress, you can find the source code for each image in the
following GitHub repositories:

*   https://github.com/GoogleCloudPlatform/cassandra-docker
*   https://github.com/GoogleCloudPlatform/elasticsearch-docker
*   https://github.com/GoogleCloudPlatform/fluentd-docker
*   https://github.com/GoogleCloudPlatform/grafana-docker
*   https://github.com/GoogleCloudPlatform/influxdb-docker
*   https://github.com/GoogleCloudPlatform/jenkins-docker
*   https://github.com/GoogleCloudPlatform/kibana-docker
*   https://github.com/GoogleCloudPlatform/kube-state-metrics-docker
*   https://github.com/GoogleCloudPlatform/mariadb-docker
*   https://github.com/GoogleCloudPlatform/memcached-docker
*   https://github.com/GoogleCloudPlatform/mongodb-docker
*   https://github.com/GoogleCloudPlatform/mysql-docker
*   https://github.com/GoogleCloudPlatform/nfs-server-docker
*   https://github.com/GoogleCloudPlatform/nginx-docker
*   https://github.com/GoogleCloudPlatform/postgresql-docker
*   https://github.com/GoogleCloudPlatform/prometheus
*   https://github.com/GoogleCloudPlatform/prometheus-alertmanager-docker
*   https://github.com/GoogleCloudPlatform/prometheus-nodeexporter-docker
*   https://github.com/GoogleCloudPlatform/prometheus-pushgateway-docker
*   https://github.com/GoogleCloudPlatform/rabbitmq-docker
*   https://github.com/GoogleCloudPlatform/redis-docker
*   https://github.com/GoogleCloudPlatform/sonarqube-docker
*   https://github.com/GoogleCloudPlatform/wordpress-docker

## Functional tests

https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/functional_tests

## Generate Dockerfile from template

https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/versioning

## Generate Cloud Build configuration

https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/versioning

## Documentation

https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/docgen

## Cloud Build CI

This repository uses Cloud Build for continuous integration. The Cloud Build
configuration file is located at
[`../cloudbuild-docker.yaml`](../cloudbuild-docker.yaml).

### Manually run the build

```shell
gcloud builds submit --config=cloudbuild-docker.yaml \
  --machine-type=n1-highcpu-8 --substitutions=_SOLUTION_NAME=[SOLUTION_NAME] .
```
