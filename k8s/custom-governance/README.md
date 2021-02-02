## Table of Contents
- [Installation](#installation)
  - [Before you get started](#before-you-get-started)
  - [Quick install with Google Cloud Marketplace](#quick-install-with-google-cloud-marketplace)
  - [Prerequisites](#prerequisites)
    - [**IMPORTANT**](#important)
  - [Option 1: Marketplace UI Deployment Details](#option-1-marketplace-ui-deployment-details)
  - [Option 2: Command Line Deployment](#option-2-command-line-deployment)
    - [Prerequisites](#prerequisites-1)
      - [Set up command line tools](#set-up-command-line-tools)
      - [Enable required APIs](#enable-required-apis)
      - [Complete resource prerequisites](#complete-resource-prerequisites)
      - [Create a Google Kubernetes Engine cluster](#create-a-google-kubernetes-engine-cluster)
      - [Configure kubectl to connect to the cluster](#configure-kubectl-to-connect-to-the-cluster)
      - [Clone this repo](#clone-this-repo)
      - [Install the Application resource definition](#install-the-application-resource-definition)
    - [Install the Application](#install-the-application)
      - [Configure the app with environment variables](#configure-the-app-with-environment-variables)
      - [Create namespace in your Kubernetes cluster](#create-namespace-in-your-kubernetes-cluster)
      - [Configure the service account](#configure-the-service-account)
      - [Add the application parameters to `cli_values_template.yaml`](#add-the-application-parameters-to-cli_values_templateyaml)
      - [Expand the manifest template](#expand-the-manifest-template)
      - [Apply the manifest to your Kubernetes cluster](#apply-the-manifest-to-your-kubernetes-cluster)
      - [Post Deployment](#post-deployment)
      - [View the app in the Google Cloud Console](#view-the-app-in-the-google-cloud-console)
  - [Detailed Instructions](#detailed-instructions)
    - [Minimum Requirements for GKE Cluster](#minimum-requirements-for-gke-cluster)
    - [Create a GKE Cluster With Custom Service Account](#create-a-gke-cluster-with-custom-service-account)
      - [Creating a custom service account for your GKE cluster](#creating-a-custom-service-account-for-your-gke-cluster)
      - [Configuring the GKE cluster to use custom service account](#configuring-the-gke-cluster-to-use-custom-service-account)
    - [Setup OAuth Credentials for IAP (Identity Aware Proxy)](#setup-oauth-credentials-for-iap-identity-aware-proxy)
    - [Reserve Static External IP Address](#reserve-static-external-ip-address)
    - [Configure DNS A Record](#configure-dns-a-record)
  - [Post Deployment](#post-deployment-1)
    - [Configure Identity-Aware Proxy (IAP)](#configure-identity-aware-proxy-iap)
    - [Finish Deployment](#finish-deployment)
  - [Troubleshooting](#troubleshooting)
    - ["You don't have access"](#you-dont-have-access)
    - ["Some components have errors"](#some-components-have-errors)
    - [“This site can't provide a secure connection”](#this-site-cant-provide-a-secure-connection)
    - [“Connection Closed”](#connection-closed)
    - [“Internal Server Error”](#internal-server-error)
    - [“Error: redirect_uri_mismatch”](#error-redirect_uri_mismatch)

Custom Governance (CG) is a customizable customer-managed governance platform which lets you coordinate the unique set of rules which make your business work as a native part of your cloud environment.

[Learn more.](https://console.cloud.google.com/marketplace/details/custom-governance/custom-governance)

## About Google Click to Deploy

Popular open stacks on Kubernetes, packaged by Google.

## Questions

Questions about Custom Governance? Go [here](https://docs.google.com/document/d/1o1x8wVrmNwWscnMDtXeTHBjK8cwBCvA6cidoSU0bEzM/edit#heading=h.huk25sxgebcs)

# Installation

## Before you get started

As of early spring 2021 the Custom Governance product is in Beta stage with allowlisting. We are taking a limited number of new customers. To try out Custom Governance, [**please request access at the Early Access Center to be allowlisted**](https://console.cloud.google.com/iam-admin/early-access-center/campaigns/87175a3a-c0ae-4551-a6f6-b586a45bdcf9/enroll-customer). You can also 
[**fill out this intake form**](https://docs.google.com/forms/d/e/1FAIpQLSejlXV2IJbH7IlUGAHDkpNc_-UFPw4oB3K1TccbuBCwvuTVwA/viewform?gxids=7826).

## Quick install with Google Cloud Marketplace

Get up and running with a few clicks! Install Custom Governance to a
Google Kubernetes Engine cluster using Google Cloud Marketplace. Follow the
[on-screen steps](https://console.cloud.google.com/marketplace/details/custom-governance/custom-governance).

Below are detailed instructions for installing Custom Governance through the Google Cloud Platform (GCP) Marketplace UI.

Custom Governance installed through Marketplace is a Kubernetes application on a Google Kubernetes Engine (GKE) cluster.

**Due to security reasons, we only support running Custom Governance in Google Chrome or Safari. Custom Governance may not be loading properly in all other browsers.**

## Prerequisites
The person performing the onboarding needs to be able to grant the following IAM roles to a service account:
* **Project Editor**
* **Dataflow Worker**
* **Storage Admin**
* **Service Account Token Creator**

The person will also need to:
* Have access to a VM/desktop/laptop that can create a private GKE cluster and ssh if using command line installation if you wish to install Custom Governance in private cluster.
* Have the ability to configure the following resource during the installation process:
  * GKE cluster
  * IAP
  * Global static IP
  * DNS A record configuration
  * **Cloud Asset Owner** role granting to the resources to be monitored

### **IMPORTANT**
We will cover these steps with detail in the installation part below, but it's good to have them in mind because they are pretty important for a successful installation.
  * **We recommend to install Custom Governance in an isloated GCP project.**
  * **Make sure you enable [Cloud Resource Manager](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com) API after you create the project where Custom Governance can be deployed.**
  * **When creating a new cluster using ***Create cluster*** button, please make sure Cloud Platform scope is enabled.**
  * **Remember to set up redirect URI after Client ID is created.**

## Option 1: Marketplace UI Deployment Details

1. [Create a project](https://cloud.google.com/resource-manager/docs/creating-managing-projects#before_you_begin)
 where Custom Governance can be deployed.
    * Remember to [enable billing in your project](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)

1. Enable [Cloud Resource Manager](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com).
   *   CRM (Cloud Resource Manager) is used by Custom Governance to read Google Cloud Platform resource metadata. It is required for Custom Governance to run.
1. Visit the Marketplace listing for [Custom Governance](https://console.cloud.google.com/marketplace/details/custom-governance/custom-governance) for information on Custom Governance. We will start installation on this page.
   *   When you are ready to deploy click on the “Configure” button, it will take you to the Deployment Configuration UI:

        ![Deployment Configuration](./images/deployment_configuration.png)

   Please follow the below instructions to finish installation.
   1. **Create a GKE cluster.** The cluster list will contain only clusters that meet the basic requirements to run Custom Governance, you can either
      *   (Recommended) Create a cluster with a custom service account to meet additional organizational requirements and a kubernetes service account, click [here for instructions and to learn about minimum requirements.](#Minimum-Requirements-for-GKE-Cluster).
      *   (Not Recommended) Create a cluster that meets the basic requirements by clicking “Create Cluster” button. 
      **Please make sure to enable "Allow access to the following Cloud APIs".** This is required for the Cluster to be able to network with GCP services. Note that in this way Custom Governance will be running on default GCE service account.
      
      After the cluster is created, you can continue with next steps.
   1. **Set up Namespace.** You can use the default namespace or select the new namespace you just created.
   1. **Set up App instance name.** This is the name of your application instance, e.g. custom-governance.
   1. **Set up OAuth Client ID and OAuth Client Secret.** Please follow the [OAuth section](#Setup-OAuth-Credentials-for-IAP-Identity-Aware-Proxy) and fill in the OAuth Client ID and OAuth Client Secret that you created there.
   1. **Set up Name of Global Static IP Address.** Please follow the instructions here on [how to create a static ip](#Reserve-Static-External-IP-Address) and fill in the name of that ip address, e.g. cg-app-ip.
   1. **Set up Domain Name to serve Custom Governance and Name of Global Static IP Address.** After a static ip is reserved, please follow [the instructions to configure a DNS A Record](#Configure-DNS-A-Record). The Domain name which needs to be filled in here refers to the name that you pointed to the static IP address through the A record. e.g. cg.example.com.
   1. **Set up Kubernetes Service Account** 
        *   If you created a custom cluster, please select the kubernetes service account you just created.
        *   If you created a cluster by clicking ***Create cluster*** button, please select ***Create a new service account***.
   2. **Set up Initial User Email.** This will be the user email address that will be deploying/setting up Custom Governance. Custom Governance will check for this email address even after the user has passed through IAP.
   3.  **Click “Deploy” when you are ready.** Deployment usually will take around ten minutes or longer. Even after deployment is successful the cg-ingress may take longer to become ready. This is completely normal. When you find cg-ingress is ready on [cloud console](https://console.cloud.google.com/kubernetes/discovery), it means that the deployment succeeds! You can jump to our [Post Deployment Section](#Post-Deployment) once it's ready. We still have a few steps before you can explore Custom Governance.

## Option 2: Command Line Deployment

You can use [Google Cloud Shell](https://cloud.google.com/shell/) or a local
workstation to follow the steps below.

[![Open in Cloud Shell](http://gstatic.com/cloudssh/images/open-btn.svg)](https://console.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/GoogleCloudPlatform/click-to-deploy&cloudshell_open_in_editor=README.md&cloudshell_working_dir=k8s/sample-app)

### Prerequisites

#### Set up command line tools

You'll need the following tools in your development environment. If you are
using Cloud Shell, `gcloud`, `kubectl`, Docker, and Git are installed in your
environment by default.

-   [gcloud](https://cloud.google.com/sdk/gcloud/)
-   [kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
-   [docker](https://docs.docker.com/install/)
-   [git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)

Configure `gcloud` as a Docker credential helper:

```shell
gcloud auth configure-docker
```

#### Enable required APIs

1. Enable [Cloud Resource Manager](https://console.cloud.google.com/apis/api/cloudresourcemanager.googleapis.com).
   *   CRM (Cloud Resource Manager) is used by Custom Governance to read Google Cloud Platform resource metadata. It is required for Custom Governance to run.

1. Enable [Kubernetes Engine API](https://console.cloud.google.com/apis/api/container.googleapis.com).
    *   Kubernetes Engine API is required to create a Kubernetes Cluster.

#### Complete resource prerequisites
  Before starting the CLI install you will need the following parameters:
  * [Enable Billing](https://cloud.google.com/billing/docs/how-to/modify-project#enable_billing_for_a_project)
  * [OAuth Client ID](#Setup-OAuth-Credentials-for-IAP-Identity-Aware-Proxy)
  * [OAuth Client Secret](#Setup-OAuth-Credentials-for-IAP-Identity-Aware-Proxy)
  * [Static IP Name](#Reserve-Static-External-IP-Address)
  * [Setup your DNS A Record and Hostname](#Configure-DNS-A-Record)
  * Initial Email: This will be the **user email address** that will be deploying/setting up Custom Governance. Custom Governance will check for this email address even after the user has passed through IAP.

#### Create a Google Kubernetes Engine cluster

Create a cluster from the command line. If you already have a cluster that you
want to use, this step is optional. You can also refer here for [instructions](#create-a-gke-cluster-with-custom-service-account) on how to create a GKE cluster with custom service account with UI but ignore steps regarding the namespace and kubernetes service account because those will be covered in the following steps. Flags are optional for the command.
More custom flags are available [here](https://cloud.google.com/sdk/gcloud/reference/container/clusters/create).

```shell
export CLUSTER=cg-cluster
export ZONE=us-west1-a
export MACHINE_TYPE="YOUR PREFERED MACHINE TYPE"
export SERVICE_ACCOUNT="YOUR CUSTOM SERVICE ACCOUNT"

gcloud container clusters create "$CLUSTER" --scopes=https://www.googleapis.com/auth/cloud-platform --zone "$ZONE" [--machine-type="$MACHINE_TYPE"] [--service-account="$SERVICE_ACCOUNT"]
```

#### Configure kubectl to connect to the cluster

```shell
gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
```

#### Clone this repo

Clone this repo and the associated tools repo:

```shell
git clone --recursive https://github.com/GoogleCloudPlatform/click-to-deploy.git
```

#### Install the Application resource definition

An Application resource is a collection of individual Kubernetes components,
such as Services, Deployments, and so on, that you can manage as a group.

To set up your cluster to understand Application resources, run the following
command:

```shell
kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
```

You need to run this command once for each cluster.

The Application resource is defined by the
[Kubernetes SIG-apps](https://github.com/kubernetes/community/tree/master/sig-apps)
community. The source code can be found on
[github.com/kubernetes-sigs/application](https://github.com/kubernetes-sigs/application).

### Install the Application

#### Configure the app with environment variables
Navigate to the `custom-governance` directory:

```shell
cd click-to-deploy/k8s/custom-governance
```

Choose an instance name and
[namespace](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
for the app. In most cases, you can use the `default` namespace.

```shell
export APP_INSTANCE_NAME=cg-app-1
export NAMESPACE=default
```

#### Create namespace in your Kubernetes cluster

If you use a different namespace than `default`, or the namespace does not exist
yet, run the command below to create a new namespace:

```shell
kubectl create namespace "${NAMESPACE}"
```
#### Configure the service account

The application needs a service account in the target namespace with cluster wide permissions to access Kubernetes resources such as Kubernetes Secrets.

Provision a service account and export the name into a variable:

```shell
kubectl create serviceaccount "${APP_INSTANCE_NAME}-sa" --namespace "${NAMESPACE}"
kubectl create clusterrolebinding "${NAMESPACE}-${APP_INSTANCE_NAME}-sa-rb" --clusterrole=edit --serviceaccount="${NAMESPACE}:${APP_INSTANCE_NAME}-sa"
export SERVICE_ACCOUNT="${APP_INSTANCE_NAME}-sa"
```
#### Add the application parameters to [`cli_values_template.yaml`](cli_values_template.yaml)

Open [`cli_values_template.yaml`](cli_values_template.yaml) inside the `custom-governance` directory:

```shell
vim cli_values_template.yaml
```

Insert the parameters you configured as part of the prerequisites.

1. Generate a base64 version of your OAuth Client ID with this command:

  ```shell
  echo -n '<YOUR OAUTH CLIENT ID>' | base64
  ```

2. Generate a base64 version of your OAuth Client Secret with this command:

  ```shell
  echo -n '<YOUR OAUTH CLIENT SECRET>' | base64
  ```

3. Static IP Name: This is the name of the Static IP you created. For example: cg-app-ip

4. Your certificate hostname is the full DNS address where Custom Governance will be hosted. For example: cg.example.com

5. Service Account: This is the name of the service account you created. For example: cg-app-1-sa
    * You can get this with ```echo $SERVICE_ACCOUNT```

6. Initial Email: This will be the user email address that will be deploying/setting up Custom Governance. Custom Governance will check for this email address even after the user has passed through IAP.


#### Expand the manifest template

Replace the values.yaml template with your template:
1. Rename the current values template

  ```shell
  mv chart/custom-governance/values.yaml values_template.yaml
  ```

2. Copy your value template into the chart:

  ```shell
  cp cli_values_template.yaml chart/custom-governance/values.yaml
  ```

Use `helm template` to expand the template. We recommend that you save the
expanded manifest file for future updates to your app.

```shell
helm template ${APP_INSTANCE_NAME} chart/custom-governance > ${APP_INSTANCE_NAME}_manifest.yaml
```

#### Apply the manifest to your Kubernetes cluster

Use `kubectl` to apply the manifest to your Kubernetes cluster:

```shell
kubectl apply -f "${APP_INSTANCE_NAME}_manifest.yaml" --namespace "${NAMESPACE}"
```
#### Post Deployment

In order to access your newly deployed Custom Governance instance you must completed
IAP setup.

Follow the instructions in [the Post Deployment section](#Post-Deployment)

#### View the app in the Google Cloud Console

To get the Cloud Console URL for your app, run the following command:

```shell
echo "https://console.cloud.google.com/kubernetes/application/${ZONE}/${CLUSTER}/${NAMESPACE}/${APP_INSTANCE_NAME}?project=${PROJECT_ID}"
```

To view the app, open the URL in your browser.

## Detailed Instructions

### Minimum Requirements for GKE Cluster

We have minimum requirements for GKE clusters running Custom Governance [following GCP Best practices](https://cloud.google.com/compute/docs/access/create-enable-service-accounts-for-instances#best_practices):

  1. We require a service account with the `editor` IAM role in order to allow Custom Governance to deploy successfully.
     * If you are deploying via [CLI installation](#Command-Line-Deployment) you will need to add the `Kubernetes Engine Admin` IAM role as well.
     * By default the Compute Engine service account is used. If you would like to create a custom service account [click here](#Create-a-GKE-Cluster-With-Custom-Service-Account).
  2. [Configure the instance to run as that service account](#configuring-the-gke-cluster-to-run-as-a-custom-service-account).
  3. Ensure the instance has the `cloud-platform` scope to allow access to Google Cloud APIs. [Learn how to create a cluster with the scope here.](https://www.googleapis.com/auth/cloud-platform)

In addition we recommend these minimum specifications for the cluster:

  * 4 vCPUs
  * 15GB memory

The `n1-standard-4` machine type is a good choice that covers the minimum requirements.

### Create a GKE Cluster With Custom Service Account

#### Creating a custom service account for your GKE cluster

1. From the Cloud Console visit [Menu > IAM & Admin > Service Accounts](https://console.cloud.google.com/iam-admin/serviceaccounts)
![Service Account 1](./images/service-account-1.png)
1. Click `Create Service Account` and give the service account a name (e.g. cg-custom-sa)
![Service Account 2](./images/service-account-2.png)
1. Chose the `Editor`, `Storage Admin`, `Dataflow Worker` and `Service Account Token Creator` role for the service account. The service account will be used to run Custom Governance.
![Service Account 3](./images/service-account-3.png)
1. Provide users with permission to utilize and administer the service account
![Service Account 4](./images/service-account-4.png)

#### Configuring the GKE cluster to use custom service account
1. From the Cloud Console visit [Menu > Kubernetes Engine > Clusters](https://console.cloud.google.com/kubernetes/list)
![Custom Service Account 1](./images/custom-sa-cluster-1.png)
1. Click into the pool (default-pool) -> Security. Select the custom service account you created earlier.
![Custom Service Account 3](./images/custom-sa-cluster-3.png)
1. Click `Create` to create your cluster with your custom SA.
1. Wait until your cluster is created before proceeding to next steps.
1. **Configure kubectl to connect to the cluster**
    ```shell
    gcloud container clusters get-credentials "$CLUSTER" --zone "$ZONE"
    ```
1. **Create namespace in your Kubernetes cluster.**
   NAMESPACE is your kubernete namespace in which you plan to install Custom Governance. In most cases, you can use the `default` namespace and ignore this step. If you decide to create a new namepace, please make sure you use the same namespace that you will select in Marketplace Configuration UI.
    ```shell
    kubectl create namespace "${NAMESPACE}"
    ```
1. **Configure the kubernetes service account.**
   The application needs a service account in the target namespace with cluster wide permissions to access Kubernetes resources such as Kubernetes Secrets. Run the following command to provision a service account and a cluster rolebinding. Please make sure you keep a note on the name of the service account you created. You need to select this service account in the Marketplace Configuration UI.
   ```shell
   kubectl create serviceaccount "${APP_INSTANCE_NAME}-sa" --namespace "${NAMESPACE}"
   kubectl create clusterrolebinding "${NAMESPACE}-${APP_INSTANCE_NAME}-sa-rb" --clusterrole=edit --serviceaccount="${NAMESPACE}:${APP_INSTANCE_NAME}-sa"
   ```

### Setup OAuth Credentials for IAP (Identity Aware Proxy)

Learn more about IAP [here](https://cloud.google.com/iap).

Custom Governance uses OAuth for authentication/authorization.
You will need to pass OAuth Credentials to Marketplace UI to properly configure IAP. Follow the instructions to create OAuth Credentials:

   1. Configuring OAuth Consent Screen. Below are detailed steps on how to configure the OAuth Consent Screen.
       1.  Via Cloud Console visit [Menu > API & Services > OAuth consent screen](https://console.cloud.google.com/apis/credentials/consent), select user type and click create.
            * Selecting External will allow accounts outside of your organization to access Custom Governance
            * Selecting Internal will allow accounts only inside your organization to access Custom Governance. **We recommend to choose Internal as the user type.**
       2.  Fill in the *App name*, *User support email* under App information, and *Email addresses* under Developer contact information. Then click save and continue.
            * *App name* is the Application name you want to display on the user consent screen. You can name it as Custom Governance.
            * For *User support email* and *Email address*, you can fill in with your own email address.
       3.  Continue clicking **SAVE AND CONTINUE** Button for the rest and it's done!

   2. Creating OAuth Credentials. Below are detailed steps on how to create the OAuth Credentials.
       1.  Via Cloud Console visit [Menu > API & Services > Credentials](https://console.cloud.google.com/apis/credentials)
       2.  Click *Create Credentials* and select *OAuth client ID*
       3.  Select *Web application* as the Application type
         ![OAuth Step 1](./images/oauth_step1.png)
       4.  Create the OAuth Credentials by clicking *Create*
       5. Copy the Client ID from the OAuth confirmation modal
         ![OAuth Step 2](./images/oauth_step2.png)
       6. Dismiss the modal and select the OAuth 2.0 Client ID that was just created
       7. Add a Authorized redirect URI that incorporates the client ID that you copied over
         ![OAuth Step 3](./images/oauth_step3.png)

           * Required URI: https://iap.googleapis.com/v1/oauth/clientIds/CLIENT_ID:handleRedirect
           * Where CLIENT_ID is your OAuth Client ID


Once you have created your OAuth Credentials you will need the following to pass into Marketplace UI:

*   OAuth client ID
*   OAuth client secret

[Click here to continue with the rest installation steps](#marketplace-ui-deployment-details)
### Reserve Static External IP Address

*   You can reserve a static external IP address through the [gcloud command-line tool](https://cloud.google.com/sdk/gcloud). In order to meet IAP requirements, we'll need to reserve a **global** IP address. You can run this command in the Cloud Shell. This command will reserve a static IP and give it a name. You'll need this name to be put in the Marketplace UI:

    `gcloud compute addresses create { NAME } --global`

    For example **cg-app-ip**:

    `gcloud compute addresses create cg-app-ip --global`

*   **Or** you can reserve static external IP address through [cloud console UI](https://console.cloud.google.com/networking/addresses/add).
    *   **You MUST choose Global as the IP address type**
    *   The name for the static address will need to be passed into the Marketplace UI. For example, you can name it as **cg-app-ip**.

*  [Click here to continue with the rest installation steps](#marketplace-ui-deployment-details)

### Configure DNS A Record

*    Run the following gcloud command to retrieve your assigned IP address. If you specified a different IP name in the previous step, please replace **cg-app-ip** with your customized name:

      `gcloud compute addresses describe cg-app-ip --global`

*   **Or** retrieve the IP through [cloud console UI](https://console.cloud.google.com/networking/addresses/list). Find the **cg-app-ip** (or your customized name if different) and the External Address is the IP address.

Then you will need to **create an A record with the assigned IP address in your DNS settings**. These DNS settings are usually handled by your host provider. Set the TTL to the minimum amount to allow for quick propagation. The **full domain name** you entered will need to be passed into the Marketplace UI. For example, you can name it as cg.example.com.
The following command can help you quickly find out if your DNS is correctly set up and propagated:

`nslookup <your domain>`

If you utilize Cloud DNS you can follow [these instructions for creating a new record](https://cloud.google.com/dns/docs/quickstart#create_a_new_record).
Once this step is completed, [Click here to continue with the rest installation steps](#marketplace-ui-deployment-details)

## Post Deployment

### Configure Identity-Aware Proxy (IAP)

After Marketplace Deployment has completed successfully you will need to configure
IAP and add any users that will require access to Custom Governance.

*   From the Cloud Console visit [Menu > Security > Identity-Aware-Proxy](https://console.cloud.google.com/security/iap).
*   Enable IAP if it is not already enabled.
*   Review any Errors and Warning as well as review the firewalls.
*   Via Cloud Console you can add users to IAP approved list. Visit
    [Menu > IAM & Admin > IAM](https://console.cloud.google.com/iam-admin/iam) and add
    the *IAP-secured Web App User* role to users you wish to grant access to
    * **Even if you are the Project Owner, you still need to be added to IAP approved list as well.**
    * **Note that IAP may need a couple of minutes to propagate.**

![IAM IAP Setup](./images/IAM_IAP_user.png)

### Finish Deployment
Once deployment is complete you can visit your host address to start the Custom Governance post-deployment process. Custom Governance will walk you through the steps to deploy the necessary resources and permissions required.


## Troubleshooting

### "You don't have access"

![IAP Access Error](./images/iap-access-error.png)

If you are getting this error when trying to access your Custom Governance instance you need to [add the user to the IAP secured user list.](#configure-identity-aware-proxy-iap)

You will need to wait a few minutes for the change to propagate.

### "Some components have errors"

You may see this error in Cloud Console after the application is deployed if the components are not ready. It can take up to half an hour or longer for the Ingress and Deployment to become ready depending on your DNS TTL.

This warning may be accompanied by others:
*   Ingress: "All backend services are in UNHEALTHY state"
*   Deployment: "Does not have minimum availability"

Please allow some time for these warnings to resolve.

### “This site can't provide a secure connection”

The site is not loading your Managed Certificate yet. Make sure you are accessing Cloud Governance by the hostname, not the Load Balancer IP. Wait a few minutes for the Managed Certificate and Load Balancer to become ready. The Managed Certificate relies on your DNS to propagate the A record before it can provision correctly. Certificate provisioning can take up to an hour or even longer. You can check the status of your certificate through kubectl:

    gcloud container clusters get-credentials <cluster name>
    kubectl describe managedcertificate managed-certificate -n <namespace>


###  “Connection Closed”

If going to the hostname results in a “Connection Closed” error, the DNS was not updated in time and certificate provisioning failed. We will need to create a new certificate:



1. Visit the Kubernetes Engine Dashboard and navigate to [Services & Ingress](https://console.cloud.google.com/kubernetes/discovery)
2. Click on the service named “cg-ingress”
3. Locate the Load Balancer under the Ingress section and click on the associated load balancer
4. Edit the Load Balancer configuration
5. Select the Frontend Configuration for editing -> choose the HTTPS frontend configuration (Port 443)
6. Click on the Certificate dropdown and select “Create a new certificate”
7. Enter a name and select “Create Google-managed certificate”, enter your domain name
8. Finish creating the certificate and click “Update” on the load balancer to confirm your changes
9. You should now get through the application
10. Delete the old certificates that are no longer in use


### “Internal Server Error”

If you get an “Internal Server Error” try checking the logs to see what the issue is. You may have not configured the OAuth Credentials properly. You can check the pod logs through Cloud Console or [through kubectl](https://www.google.com/url?q=https://cloud.google.com/kubernetes-engine/docs/quickstart):


```
kubectl get pods
kubectl logs POD_NAME
```



### “Error: redirect_uri_mismatch”

If you are getting this error after logging in you have not[ setup OAuth](https://cloud.google.com/iap/docs/enabling-kubernetes-howto#oauth-credentials) authorized redirect URIs to include the universal redirect URL.

Add to your OAuth authorized redirect URIs:


```
 https://iap.googleapis.com/v1/oauth/clientIds/CLIENT_ID:handleRedirect
```


Where CLIENT_ID is your OAuth Client ID.
