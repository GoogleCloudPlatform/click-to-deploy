# Cloud Build triggers for a GitHub repository

We use Google Cloud Build (GCB) triggers to test applications.

For more information, see the
[`gcloud alpha builds triggers`](https://cloud.google.com/sdk/gcloud/reference/alpha/builds/triggers/)
commands.

## Create or update a trigger

*   Run the following command to create or update a trigger for your Kubernetes
    application:

    > **NOTE**: You can only update an existing trigger if its
    > configuration file contains either that trigger's name or trigger
    > ID. If neither are present within the configuration file, a new
    > trigger will be created.

    > **IMPORTANT**: Mark newly created triggers as required in repository settings.

    ```shell
    gcloud alpha builds triggers import \
      --source k8s/[APP_NAME].yaml \
      --project [PROJECT_ID]
    ```

    Where:

    *   `[APP_NAME]` is the application name for which you want to create a
        trigger.
    *   `[PROJECT_ID]` is the GCP project ID of the project where the trigger will be created.

## Export an existing trigger

*   Run the following command to export an existing trigger to a file for your
    Kubernetes application:

    ```shell
    gcloud alpha builds triggers export [TRIGGER] \
      --destination k8s/[APP_NAME].yaml \
      --project [PROJECT_ID]
    ```

    Where:

    *   `[TRIGGER]` is the trigger's ID or fully qualified identifier.
    *   `[APP_NAME]` is the name of the application whose configuration you want to
        export.
    *   `[PROJECT_ID]` is the GCP project ID of the project where the trigger will
        be exported.

## Get details about an existing trigger

*   Run the following command to get details of an existing trigger:

    ```shell
    gcloud alpha builds triggers list \
      --filter="filename:cloudbuild-k8s.yaml AND substitutions._SOLUTION_NAME:[APP_NAME]" \
      --project [PROJECT_ID]
    ```
