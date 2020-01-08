# Cloud Build triggers for a GitHub repository

We use Google Cloud Build (GCB) triggers to test applications.

For more information, see the
[`gcloud alpha builds triggers`](https://cloud.google.com/sdk/gcloud/reference/alpha/builds/triggers/)
commands.

## Kubernetes apps

The following sections are concerned to Kubernetes apps.

### Create a new trigger

1.  Make a copy of an existing config file:

    ```shell
    cp k8s/mariadb-galera.yaml "k8s/$APP_NAME.yaml"
    sed -i "s/mariadb-galera/$APP_NAME/g" "k8s/$APP_NAME.yaml"
    sed -i '/^\s\sinstallationId/d' "k8s/$APP_NAME.yaml"
    sed -i '/^id/d' "k8s/$APP_NAME.yaml"
    ```

1.  Open the config file and verify that everything looks correct:

    ```shell
    cat "k8s/$APP_NAME.yaml"
    ```

1.  Run the following command to create a trigger for your Kubernetes
    application:

    ```shell
    gcloud alpha builds triggers create github \
      --trigger-config k8s/$APP_NAME.yaml \
      --project $PROJECT_ID
    ```

    Where:

    *   `$APP_NAME` is the application name for which you want to create a
        trigger.
    *   `$PROJECT_ID` is the GCP project ID of the project where the trigger will be created.
    
1.  Mark the newly created trigger as required in the GitHub repository settings. For more information, see the [enabling required status checks](https://help.github.com/en/articles/enabling-required-status-checks) documentation.

    > **NOTE**: The trigger must be triggered initially before it is available in the list.

### Update an existing trigger

1.  Run the following command to update a trigger for your Kubernetes
    application:

    > **NOTE**: You can only update an existing trigger if its
    > configuration file contains either that trigger's name or trigger
    > ID. If neither are present within the configuration file, a new
    > trigger will be created.

    ```shell
    gcloud alpha builds triggers import \
      --source k8s/$APP_NAME.yaml \
      --project $PROJECT_ID
    ```

    Where:

    *   `$APP_NAME` is the application name for which you want to update the
        trigger.
    *   `$PROJECT_ID` is the GCP project ID of the project where the trigger will be updated.

### Export an existing trigger

1.  Run the following command to export an existing trigger to a file for your
    Kubernetes application:

    ```shell
    gcloud alpha builds triggers export $TRIGGER \
      --destination k8s/$APP_NAME.yaml \
      --project $PROJECT_ID
    ```

    Where:

    *   `$TRIGGER` is a trigger's ID or fully qualified identifier.
    *   `$APP_NAME` is the name of the application whose configuration you want to
        export.
    *   `$PROJECT_ID` is the GCP project ID of the project where the trigger will
        be exported.

### Get the details of an existing trigger

1.  Run the following command to get details of an existing trigger:

    ```shell
    gcloud alpha builds triggers list \
      --filter="filename:cloudbuild-k8s.yaml AND substitutions._SOLUTION_NAME:$APP_NAME" \
      --project $PROJECT_ID
    ```
