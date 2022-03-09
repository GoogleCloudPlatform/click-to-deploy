# solr-docker

Container solution for Apache Solr.
Learn more about Apache Solr in [official documentation](https://lucene.apache.org/solr/).

## Upstream

- Source for [Apache Solr docker solution](https://github.com/docker-solr/docker-solr/)

## Disclaimer

This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Apache Solr.

For more information, see the
[Official Image Marketplace Page](https://console.cloud.google.com/marketplace/details/google/solr).

### Prerequisites

Configure [gcloud](https://cloud.google.com/sdk/gcloud/) as a Docker credential helper:

```shell
gcloud auth configure-docker
```
### Pull command

```shell
docker -- pull marketplace.gcr.io/google/solr8
```
Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker/solr/8/debian10/8.11/)
