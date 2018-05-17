# Continuous Integration

Steps for setting up GCP container builder to run integration tests on the applications.

## Requirements:

- Github [repository](https://help.github.com/articles/create-a-repo/) that will be built
- GCP [project](https://cloud.google.com/resource-manager/docs/creating-managing-projects)
- GCP [storage bucket](https://cloud.google.com/storage/docs/creating-buckets)

## Create a Kubernetes cluster

Instructions for creating a [kubernetes cluster](https://cloud.google.com/kubernetes-engine/docs/how-to/creating-a-container-cluster).

The __cluster name__ and the __cluster location__ will be used in the build definition.

## Create a build trigger

Instructions for creating a [build trigger](https://cloud.google.com/container-builder/docs/running-builds/automate-builds).

In the __Substitutions__ session, create these variables and assign the values:

- `_CLUSTER_NAME`
- `_CLUSTER_LOCATION` 
- `_REPO_NAME` Name of the github repository in the format _username/repository_name_

## Create or reuse a github app

Instructions for creating a [github app](https://developer.github.com/apps/building-github-apps/creating-a-github-app/).

Generate a secret for the application and download the file.

Run `provision_github_app_key.sh` to store the key in storage bucket.

`./provision_github_deploy_key.sh --githubapp=name_of_the_app --keyfile=path_to_secret --bucket=url_to_storage_bucket`

In the build steps, download key using gsutil. Example below assumes `--githubapp=cloudbuild`.

```yaml
steps:
...
- name: 'gcr.io/cloud-builders/gsutil'
  args:
  - cp
  - <url_to_storage_bucket>/appkeys/cloudbuild
  - cloudbuild.pem
```

## Authorize cloud build to access cluster

Add __Kubernetes Cluster Admin__ role to the cloud builder service account.

Instructions for [adding role to a service
account](https://cloud.google.com/iam/docs/granting-roles-to-service-accounts)

## If repo uses private git submodules (optional)

Run `provision_github_deploy_key.sh` to create a deploy key to be added to the submodule. Follow instructions from the command.

`./provision_github_deploy_key.sh --repo=path_to_repo --bucket=url_to_storage_bucket`

This need to be done for each submodule, recursively.

In the build steps, download each of one of the deploy keys using gsutil. Example below assumes --repo=googlecloudplatform/marketplace-k8s-app-tools

```yaml
steps:
...
- name: 'gcr.io/cloud-builders/gsutil'
  args:
  - cp
  - <url_to_storage_bucket>/deploykeys/googlecloudplatform_marketplace-k8s-app-tools
  - googlecloudplatform_marketplace-k8s-app-tools
```