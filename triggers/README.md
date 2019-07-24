# Create a build trigger for a GitHub repository

We use Google Cloud Build (GCB) triggers to test the applications.

*   Run the following command to create a trigger for your Kubernetes
    application:

    ```shell
    gcloud alpha builds triggers create github \
      --trigger_config k8s/[APP_NAME].yaml \
      --project [PROJECT_ID]
    ```

    Where:

    *   `[APP_NAME]` is the application name for which you want to create a
        trigger.
    *   `[PROJECT_ID]` is the GCP project ID where the trigger will be created.

*   Run the following command to get details of an existing trigger:

    ```shell
    gcloud alpha builds triggers list \
      --filter="filename:cloudbuild-k8s.yaml AND substitutions._SOLUTION_NAME:[APP_NAME]" \
      --project [PROJECT_ID]
    ```

For more information, see the
[`gcloud alpha builds triggers`](https://cloud.google.com/sdk/gcloud/reference/alpha/builds/triggers/)
commands.
