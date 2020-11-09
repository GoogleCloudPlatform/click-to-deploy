# Setting Up for Marketplace Solution

This document provides step-by-step instructions to prepare a GCP project for deploying Voucher marketplace solution.

All steps need to be completed for the Voucher solution to function properly. For simplicity, we recommend completing these steps before deploying Voucher on Marketplace. Although most steps can be completed after deployment (except that Voucher has to be deployed on a Workload Identity-enabled cluster).

- Enable required GCP services  
- Create a KMS signing key
- Create a Container Analysis note
- Create a GKE cluster enabled with [Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity)
- Create and configure a GCP Service Account
- Setup Workload Identity mapping

## Setup

To start, set the GCP project for `gcloud`.

  ```shell
  export PROJECT_ID=[PROJECT ID]
  gcloud config set project $PROJECT_ID
  ```

## Enable GCP services

The Voucher solution utilizes the following GCP services that need to be enabled:

  ```shell
  gcloud services enable \
    containerregistry.googleapis.com \
    containeranalysis.googleapis.com \
    containerscanning.googleapis.com \
    cloudkms.googleapis.com \
    iamcredentials.googleapis.com
  ```

## Create KMS signing key

Run the following commands to create a new KMS signing key and save the full resource ID.
Alternative key ring and key name can be configured via `KEY_RING` and `KEY_NAME`. 

  ```shell
  export KEY_RING=my-key-ring-1
  export KEY_NAME=my-signing-key-1

  gcloud kms keyrings create $KEY_RING\
     --location global

  gcloud kms keys create $KEY_NAME \
    --keyring $KEY_RING \
    --location global \
    --purpose "asymmetric-signing" \
    --default-algorithm "rsa-sign-pkcs1-4096-sha512"

  export KMS_RESOURCE_ID=projects/$PROJECT_ID/locations/global/keyRings/$KEY_RING/cryptoKeys/$KEY_NAME/cryptoKeyVersions/1
  ```

## Create Container Analysis note

The Voucher solution runs the `snakeoil` test, and creates attestations under a note ID with the same name. Run the following commands to create this note:

  ```shell
  export NOTE_ID=snakeoil
  export NOTE_NAME=projects/$PROJECT_ID/notes/$NOTE_ID
   
  cat > /tmp/note_payload.json << EOM
  {
    "name": "${NOTE_NAME}",
    "attestation": {
      "hint": {
        "human_readable_name": "voucher note for snakeoil check"
      }
    }
  }
  EOM

  curl -X POST \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer $(gcloud --project ${PROJECT_ID} auth print-access-token)"  \
    -H "x-goog-user-project: ${PROJECT_ID}" \
    --data-binary @/tmp/note_payload.json  \
  "https://containeranalysis.googleapis.com/v1/projects/${PROJECT_ID}/notes/?noteId=${NOTE_ID}"
  ```

## Create Workload Identity-enabled GKE cluster

Create a GKE cluster with Workload Identity (WI) enabled.
This step has to be run before Voucher solution is deployed. 

Ensure that the IAM Service Account Credentials API `iamcredentials.googleapis.com` has been enabled before running this.
Alternative cluster name can be configured via `CLUSTER_NAME`. 

  ```shell
  export CLUSTER_NAME=voucher-cluster-1

  gcloud container clusters create $CLUSTER_NAME \
    --workload-pool=$PROJECT_ID.svc.id.goog
  ```

## Create and configure GCP service account

In order to access GCP services, a GCP service account needs to created.
Alternative service account name can be configured via `GCP_SERVICE_ACCOUNT_NAME`.

  ```shell
  export GCP_SERVICE_ACCOUNT_NAME=voucher

  gcloud iam service-accounts create $GCP_SERVICE_ACCOUNT_NAME

  export GCP_SERVICE_ACCOUNT_EMAIL=$GCP_SERVICE_ACCOUNT_NAME@$PROJECT_ID.iam.gserviceaccount.com
  ```

Now the service account needs to be granted with the following permissions:
- `cloudkms.signer` role on the created KMS key
- `containeranalysis.notes.occurrences.viewer` role to view vulnerabilities
- `containeranalysis.occurrences.editor` role to create attestations

    ```shell    
    gcloud kms keys add-iam-policy-binding\
      $KEY_NAME --keyring=$KEY_RING\
      --location=global\
      --member=serviceAccount:$GCP_SERVICE_ACCOUNT_EMAIL\
      --role=roles/cloudkms.signer

    gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member serviceAccount:$GCP_SERVICE_ACCOUNT_EMAIL \
     --role roles/containeranalysis.notes.occurrences.viewer

    gcloud projects add-iam-policy-binding $PROJECT_ID \
     --member serviceAccount:$GCP_SERVICE_ACCOUNT_EMAIL \
     --role roles/containeranalysis.occurrences.editor
    ```

## Setup Workload Identity mapping

In order for the Voucher application to access GCP services, it needs to be run with a k8s service account that is mapped to the created GCP service account, using Workload Identity.

First configure access to the cluster for the `kubectl` tool.

  ```shell
  gcloud container clusters get-credentials $CLUSTER_NAME
  ```

Create a namespace. This step can be skipped if the default namespace is used.
Alternative namespace can be configured via `NAMESPACE`.

  ```shell
  export NAMESPACE=voucher
  kubectl create namespace $NAMESPACE
  ```

Create the k8s service account.
Alternative k8s service account name can be configured via `K8S_SERVICE_ACCOUNT_NAME`.

  ```shell
  kubectl create serviceaccount --namespace $NAMESPACE $K8S_SERVICE_ACCOUNT_NAME
  ```

Add IAM policy binding between the k8s service account and the GCP service account.

  ```shell
  gcloud iam service-accounts add-iam-policy-binding \
    --role roles/iam.workloadIdentityUser \
    --member "serviceAccount:$PROJECT_ID.svc.id.goog[$NAMESPACE/$K8S_SERVICE_ACCOUNT_NAME]" \
    $GCP_SERVICE_ACCOUNT_EMAIL
  ```

Annotate the k8s service account.

  ```shell
  kubectl annotate serviceaccount \
    --namespace $NAMESPACE \
    $K8S_SERVICE_ACCOUNT_NAME \
    iam.gke.io/gcp-service-account=$GCP_SERVICE_ACCOUNT_EMAIL
  ```
