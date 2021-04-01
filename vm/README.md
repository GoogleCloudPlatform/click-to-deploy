# Google Click to Deploy Images

## About

This directory hosts the source code of Google Click to Deploy VM images available through Google Cloud Platform Marketplace.

## Disclaimer

This is not an officially supported Google product.

## Repository structure

*   [chef](chef) directory:

    Contains [Chef](https://www.chef.io/chef/) cookbooks that install
    packages, tools and scripts, and configure the applications and
    services running on the VM instances.

    The cookbooks are designed for reuse, and several
    of the solutions are built using more than one cookbook. For example, the
    [Redmine](https://console.cloud.google.com/marketplace/details/click-to-deploy-images/redmine)
    solution is built using the `apache` and `mysql` cookbooks, and
    [Alfresco Community Edition](https://console.cloud.google.com/marketplace/details/click-to-deploy-images/alfresco)
    uses the `openjdk8`, `apache` and `postgesql` cookbooks.

    The [`c2d-config`](chef/cookbooks/c2d-config) cookbook is
    used by all Click to Deploy Images solutions. It automatically
    configures startup and utility scripts, installs useful packages,
    and configures the swap space.

*   [packer](packer) directory:

    [Packer](https://www.packer.io/) is a tool for building VM images, based on
    a wide range of available _provisioners_.

    In Click to Deploy Images solutions, Packer is used to create VM
    instances from a preset base OS image, using
    [Google Compute Builder](https://www.packer.io/docs/builders/googlecompute.html),
    and by running Chef cookbooks with
    [Chef Solo Provisioner](https://www.packer.io/docs/provisioners/chef-solo.html).
    The image is then configured using
    [Shell Provisioner](https://www.packer.io/docs/provisioners/shell.html).

    After you run the Packer build, the VM image is stored in your GCP
    project.

*   [tests](tests) directory:

    There are two types of tests that are run against the newly-created images:

    1.  Bash scripts executed on each image and verifying coverage of common the
        requirements, stored in [`tests/common`](tests/common).
    1.  Solution-specific tests run with [Serverspec](https://serverspec.org),
        stored in [`tests/solutions`](tests/solutions).

## Build an image in a local environment

Use the following steps to build a Click to Deploy solution's VM image.

### Clone this repository

```
git clone https://github.com/GoogleCloudPlatform/click-to-deploy.git
cd click-to-deploy/vm
```

### Build a VM image using the container image

To build an image, use `imagebuilder`. For information on Imagebuilder,
see the [marketplace-vm-imagebuilder](https://github.com/GoogleCloudPlatform/marketplace-vm-imagebuilder)
repository.

To pull the `imagebuilder` container image, run the following `docker`
command:

```shell
docker pull gcr.io/cloud-marketplace-tools/vm/imagebuilder:0.1.6
```

The container uses a GCP service account JSON key to access the GCP project,
create VM instances, and save the VM image. For information
about creating and managing service accounts in GCP, see the GCP documentation
for
[Creating and managing service accounts](https://cloud.google.com/iam/docs/creating-managing-service-accounts)
and
[Managing roles and permissions](https://cloud.google.com/iam/docs/granting-changing-revoking-access).

The rest of this guide assumes that the absolute path to the
service account key is stored in the `KEY_FILE_PATH` environment variable.

Set the environment variable for the absolute path to the service account key:

```shell
export KEY_FILE_PATH=<ABSOLUTE PATH FOR THE SERVICE ACCOUNT KEY>
```

Set the environment variables for the GCP project name, Google Cloud Storage (GCS)
bucket name, and solution to be built:

```shell
export PROJECT=<YOUR GCP PROJECT>
export BUCKET=<GCS BUCKET NAME TO STORE BUILD LOGS>
export SOLUTION_NAME=<VM IMAGE TO BE BUILT>
```

Now you can use the `imagebuilder` container to build the VM image:

```shell
docker run \
  -v "$PWD/packer:/packer:ro" \
  -v "$PWD/chef:/chef:ro" \
  -v "$PWD/tests:/tests:ro" \
  -v "$KEY_FILE_PATH:/service-account.json:ro" \
  -e "PROJECT=$PROJECT" \
  -e "BUCKET=$BUCKET" \
  -e "SOLUTION_NAME=$SOLUTION_NAME" \
  -e "RUN_TESTS=true" \
  -e "ATTACH_LICENSE=true" \
  -e "LICENSE_PROJECT_NAME=click-to-deploy-images" \
  -e "TESTS_CUSTOM_METADATA=google-c2d-startup-enable=0" \
  gcr.io/cloud-marketplace-tools/vm/imagebuilder:0.1.6
```

For more configuration options, see
[Volume mounts](https://github.com/GoogleCloudPlatform/marketplace-vm-imagebuilder/blob/master/README.md#volume-mounts)
and
[Environment variables](https://github.com/GoogleCloudPlatform/marketplace-vm-imagebuilder/blob/master/README.md#environment-variables).

## Cloud Build CI

This repository uses Cloud Build for continuous integration. The Cloud Build
configuration file for VM apps is located at
[`../cloudbuild-vm.yaml`](../cloudbuild-vm.yaml).

### Manually run the build

Cloud Build can be triggered manually by running the following command from the
root directory of this repository:

```shell
export GCP_PROJECT_TO_RUN_CLOUD_BUILD=<YOUR PROJECT ID>
export PACKER_LOGS_GCS_BUCKET_NAME=<GCS BUCKET TO EXPORT PACKER LOGS>
export SERVICE_ACCOUNT_KEY_JSON_GCS=gs://<GCS URL TO SERVICE ACCOUNT JSON KEY>
export SOLUTION_NAME=<VM IMAGE TO BE BUILT>

gcloud builds submit . \
  --config cloudbuild-vm.yaml \
  --substitutions _LOGS_BUCKET=$PACKER_LOGS_GCS_BUCKET_NAME,_SERVICE_ACCOUNT_JSON_GCS=$SERVICE_ACCOUNT_KEY_JSON_GCS,_SOLUTION_NAME=$SOLUTION_NAME \
  --project $GCP_PROJECT_TO_RUN_CLOUD_BUILD
```

### Build steps

1.  The service account JSON key is downloaded from the GCS bucket to
    Cloud Build's workspace.
1.  After the above step is executed successfully, the `imagebuilder` container runs and builds
    the VM image defined in the `$_SOLUTION_NAME` variable.

## Foodcritic

We use [Foodcritic](http://www.foodcritic.io/) as a lint tool for Chef cookbooks. Disabled rules are included in [`.foodcritic`](chef/.foodcritic) file.

## Cookstyle

We use [Cookstyle](https://github.com/chef/cookstyle) as a lint tool for Chef cookbooks. Disabled rules are included in [`.rubocop.yml`](chef/.rubocop.yml) file.
