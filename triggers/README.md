# Create a build trigger for a GitHub repository

We use Google Cloud Build (GCB) triggers for testing the applications.

Run the following command to create a trigger for k8s application.

```shell
gcloud alpha builds triggers create github --trigger_config k8s/[SOLUTION_NAME].yaml --project [PROJECT_ID]
```

Where:

*   `[SOLUTION_NAME]` is the solution name for which you want to create a
    trigger.
*   `[PROJECT_ID]` is the GCP project ID where you want to a trigger.

For more information, see the
[gcloud alpha builds triggers](https://cloud.google.com/sdk/gcloud/reference/alpha/builds/triggers/)
commands.
