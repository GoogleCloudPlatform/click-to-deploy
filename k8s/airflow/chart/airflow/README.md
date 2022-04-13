# Airflow Helm Chart (User Community)

__Previously known as `stable/airflow`__

[![Artifact HUB](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/airflow-helm)](https://artifacthub.io/packages/helm/airflow-helm/airflow)

## About

The `Airflow Helm Chart (User Community)` provides a standard way to deploy [Apache Airflow](https://airflow.apache.org/) on Kubernetes with Helm, and is used by thousands of companies for production deployments of Airflow.

### Goals:

(1) Ease of Use<br>
(2) Great Documentation<br>
(3) Support for older Airflow Versions<br>
(4) Support for Kubernetes GitOps Tools (like ArgoCD)

### History:

The `Airflow Helm Chart (User Community)` is a popular alternative to the official chart released in 2021 inside the `apache/airflow` git repository.
It was created in 2018 and was previously called `stable/airflow` when it lived in the (now end-of-life) [helm/charts](https://github.com/helm/charts/tree/master/stable/airflow) repository.

### Airflow Version Support:

Chart Version → <br> Airflow Version ↓  | `7.X.X` | `8.X.X`  |
--- | --- | ---
`1.10.X` | ✅ | ✅️ <sub>[1]</sub>
`2.0.X`| ❌ | ✅
`2.1.X`| ❌ | ✅

<sub>[1] you must set `airflow.legacyCommands = true` to use airflow version `1.10.X` with chart version `8.X.X`

### Airflow Executor Support:

Chart Version → <br> Airflow Executor ↓ | `7.X.X` | `8.X.X` | 
--- | --- | ---
`CeleryExecutor` | ✅ | ✅
`KubernetesExecutor` | ✅️ <sub>[1]</sub> | ✅
`CeleryKubernetesExecutor` | ❌ | ✅

<sub>[1] we encourage you to use chart version `8.X.X`, so you can use the `airflow.kubernetesPodTemplate.*` values (note, requires airflow `1.10.11+`, as it uses [AIRFLOW__KUBERNETES__POD_TEMPLATE_FILE](https://airflow.apache.org/docs/apache-airflow/2.1.0/configurations-ref.html#pod-template-file))


## Quickstart Guide

### Install:

__(Step 1) - Add this helm repository:__
```sh
## add this helm repository & pull updates from it
helm repo add airflow-stable https://airflow-helm.github.io/charts
helm repo update
```

__(Step 2) - Install this chart:__
```sh
## set the release-name & namespace
export AIRFLOW_NAME="airflow-cluster"
export AIRFLOW_NAMESPACE="airflow-cluster"

## install using helm 3
helm install \
  $AIRFLOW_NAME \
  airflow-stable/airflow \
  --namespace $AIRFLOW_NAMESPACE \
  --version "8.X.X" \
  --values ./custom-values.yaml
  
## wait until the above command returns (may take a while)
```

__(Step 3) - Locally expose the airflow webserver:__
```sh
## port-forward the airflow webserver
kubectl port-forward svc/${AIRFLOW_NAME}-web 8080:8080 --namespace $AIRFLOW_NAMESPACE

## open your browser to: http://localhost:8080 
## default login: admin/admin
```

### Upgrade:

> __WARNING__: always consult the [CHANGELOG](CHANGELOG.md) before upgrading chart versions

```yaml
## pull updates from the helm repository
helm repo update

## apply any new values // upgrade chart version to 8.X.X
helm upgrade \
  $AIRFLOW_NAME \
  airflow-stable/airflow \
  --namespace $AIRFLOW_NAMESPACE \
  --version "8.X.X" \
  --values ./custom-values.yaml
```

### Uninstall:

```yaml
## uninstall the chart
helm uninstall $AIRFLOW_NAME --namespace $AIRFLOW_NAMESPACE
```

### Examples:

To help you create your `custom-values.yaml` file, we provide some examples for common situations:

- ["Minikube - CeleryExecutor"](examples/minikube/custom-values.yaml)
- ["Google (GKE) - CeleryExecutor"](examples/google-gke/custom-values.yaml)

### Frequently Asked Questions:

> __NOTE:__ some values are not discussed in the `FAQ`, you can view the default [values.yaml](values.yaml) file for a full list of values

Review the FAQ to understand how the chart functions, here are some good starting points:

- ["How to use a specific version of airflow?"](#how-to-use-a-specific-version-of-airflow)
- ["How to set airflow configs?"](#how-to-set-airflow-configs)
- ["How to create airflow users?"](#how-to-create-airflow-users)
- ["How to authenticate airflow users with LDAP/OAUTH?"](#how-to-authenticate-airflow-users-with-ldapoauth)
- ["How to create airflow connections?"](#how-to-create-airflow-connections)
- ["How to use an external database?"](#how-to-use-an-external-database)
- ["How to persist airflow logs?"](#how-to-persist-airflow-logs)
- ["How to set up an Ingress?"](#how-to-set-up-an-ingress)

## FAQ - Airflow

> __Frequently asked questions related to airflow configs__

### How to use a specific version of airflow?
<details>
<summary>Expand</summary>
<hr>

There will always be a single default version of airflow shipped with this chart, see `airflow.image.*` in [values.yaml](values.yaml) for the current one, but other versions are supported, please see the [Airflow Version Support](#airflow-version-support) matrix.

For example, using airflow `2.0.1`, with python `3.6`:
```yaml
airflow:
  image:
    repository: apache/airflow
    tag: 2.0.1-python3.6
```

For example, using airflow `1.10.15`, with python `3.8`:
```yaml
airflow:
  # this must be "true" for airflow 1.10
  legacyCommands: true
  
  image:
    repository: apache/airflow
    tag: 1.10.15-python3.8
```

<hr>
</details>

### How to set airflow configs?
<details>
<summary>Expand</summary>
<hr>

While we don't expose the "airflow.cfg" file directly, you can use [environment variables](https://airflow.apache.org/docs/stable/howto/set-config.html) to set Airflow configs.

The `airflow.config` value makes this easier, each key-value is mounted as an environment variable on each scheduler/web/worker/flower Pod:
```yaml
airflow:
  config:
    ## security
    AIRFLOW__WEBSERVER__EXPOSE_CONFIG: "False"
    
    ## dags
    AIRFLOW__CORE__LOAD_EXAMPLES: "False"
    AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: "30"
    
    ## email
    AIRFLOW__EMAIL__EMAIL_BACKEND: "airflow.utils.email.send_email_smtp"
    AIRFLOW__SMTP__SMTP_HOST: "smtpmail.example.com"
    AIRFLOW__SMTP__SMTP_MAIL_FROM: "admin@example.com"
    AIRFLOW__SMTP__SMTP_PORT: "25"
    AIRFLOW__SMTP__SMTP_SSL: "False"
    AIRFLOW__SMTP__SMTP_STARTTLS: "False"
    
    ## domain used in airflow emails
    AIRFLOW__WEBSERVER__BASE_URL: "http://airflow.example.com"
    
    ## ether environment variables
    HTTP_PROXY: "http://proxy.example.com:8080"
```

If you want to set [cluster policies](https://airflow.apache.org/docs/apache-airflow/stable/concepts/cluster-policies.html) with an `airflow_local_settings.py` file, you can use the `airflow.localSettings.*` values:
```yaml
airflow:
  localSettings:
    ## the full content of the `airflow_local_settings.py` file (as a string)
    stringOverride: |
      # use a custom `xcom_sidecar` image for KubernetesPodOperator()
      from airflow.kubernetes.pod_generator import PodDefaults
      PodDefaults.SIDECAR_CONTAINER.image = "gcr.io/PROJECT-ID/custom-sidecar-image"
      
    ## the name of a Secret containing a `airflow_local_settings.py` key
    ## (if set, this disables `airflow.localSettings.stringOverride`)
    #existingSecret: "my-airflow-local-settings"
```

<hr>
</details>

### How to store DAGs?
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1a - git-sync sidecar (SSH auth)</h3>

This method uses an SSH git-sync sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

Example values defining an SSH git repo:
```yaml
airflow:
  config:
    AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

dags:
  gitSync:
    enabled: true
    repo: "git@github.com:USERNAME/REPOSITORY.git"
    branch: "master"
    revision: "HEAD"
    syncWait: 60
    sshSecret: "airflow-ssh-git-secret"
    sshSecretKey: "id_rsa"
    
    # "known_hosts" verification can be disabled by setting to "" 
    sshKnownHosts: |-
      github.com ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAq2A7hRGmdnm9tUDbO9IDSwBK6TbQa+PXYPCPy6rbTrTtw7PHkccKrpp0yVhp5HdEIcKr6pLlVDBfOLX9QUsyCOV0wzfjIJNlGEYsdlLJizHhbn2mUjvSAHQqZETYP81eFzLQNnPHt4EVVUh7VfDESU84KezmD5QlWpXLmvU31/yMf+Se8xhHTvKSCZIFImWwoG6mbUoWf9nzpIoaSjB+weqqUUmpaaasXVal72J+UX2B+2RPW3RcT0eOzQgqlJL3RKrTJvdsjE3JEAvGq3lGHSZXy28G3skua2SmVi/w4yCE6gbODqnTWlg7+wC604ydGXA8VJiS5ap43JXiUFFAaQ==
```

You can create the `airflow-ssh-git-secret` Secret using:
```console
kubectl create secret generic \
  airflow-ssh-git-secret \
  --from-file=id_rsa=$HOME/.ssh/id_rsa \
  --namespace my-airflow-namespace
```

<h3>Option 1b - git-sync sidecar (HTTP auth)</h3>

This method uses an HTTP git sidecar to sync your git repo into the dag folder every `dags.gitSync.syncWait` seconds.

Example values defining an HTTP git repo:
```yaml
airflow:
  config:
    AIRFLOW__SCHEDULER__DAG_DIR_LIST_INTERVAL: 60

dags:
  gitSync:
    enabled: true
    repo: "https://github.com/USERNAME/REPOSITORY.git"
    branch: "master"
    revision: "HEAD"
    syncWait: 60
    httpSecret: "airflow-http-git-secret"
    httpSecretUsernameKey: username
    httpSecretPasswordKey: password
```

You can create `airflow-http-git-secret` Secret using:
```console
kubectl create secret generic \
  airflow-http-git-secret \
  --from-literal=username=MY_GIT_USERNAME \
  --from-literal=password=MY_GIT_TOKEN \
  --namespace my-airflow-namespace
```

<h3>Option 2a - PersistentVolumeClaim (chart-managed)</h3>

With this method, you store your DAGs in a Kubernetes PersistentVolume, which is mounted to all scheduler/web/worker Pods.
You must configure some external system to ensure this volume has your latest DAGs.
For example, you could use your CI/CD pipeline system to preform a sync as changes are pushed to your DAGs git repo.

Example values to create a PVC with the `storageClass` called `default` and 1Gi initial `size`:
```yaml
dags:
  persistence:
    enabled: true
    storageClass: default
    accessMode: ReadOnlyMany
    size: 1Gi
```

<h3>Option 2b - PersistentVolumeClaim (existing / user-managed)</h3>

> 🟨 __Note__ 🟨
>
> Your `dags.persistence.existingClaim` PVC must support `ReadOnlyMany` or `ReadWriteMany` for `accessMode`

Example values to use an existing PVC called `my-dags-pvc`:
```yaml
dags:
  persistence:
    enabled: true
    existingClaim: my-dags-pvc
    accessMode: ReadOnlyMany
```

<h3>Option 3 - embedded into container image</h3>

> 🟨 __Note__ 🟨 
> 
> This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, consult airflow's official [docs about custom images](https://airflow.apache.org/docs/apache-airflow/2.0.1/production-deployment.html#production-container-images)

This method stores your DAGs inside the container image.

Example extending `airflow:2.0.1-python3.8` with some dags:
```dockerfile
FROM apache/airflow:2.0.1-python3.8

# NOTE: dag path is set with the `dags.path` value
COPY ./my_dag_folder /opt/airflow/dags
```

Example values to use `MY_REPO:MY_TAG` container image with the chart:
```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG
```

<hr>
</details>

### How to install extra pip packages?
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - use init-containers</h3>

> 🟥 __Warning__ 🟥 
> 
> We strongly advice that you DO NOT TO USE this feature in production, instead please use "Option 2"

You can use the `airflow.extraPipPackages` value to install pip packages on all Pods, you can also use the more specific `scheduler.extraPipPackages`, `web.extraPipPackages`, `worker.extraPipPackages` and `flower.extraPipPackages`.
Packages defined with the more specific values will take precedence over `airflow.extraPipPackages`, as they are listed at the end of the `pip install ...` command, and pip takes the package version which is __defined last__.

Example values for installing the `airflow-exporter` package on all scheduler/web/worker/flower Pods:
```yaml
airflow:
  extraPipPackages:
    - "airflow-exporter~=1.4.1"
```

Example values for installing PyTorch on the scheduler/worker Pods only:
```yaml
scheduler:
  extraPipPackages:
    - "torch~=1.8.0"

worker:
  extraPipPackages:
    - "torch~=1.8.0"
```

Example values to install pip packages from a private pip `--index-url`:
```yaml
airflow:
  config:
    ## pip configs can be set with environment variables
    PIP_TIMEOUT: 60
    PIP_INDEX_URL: https://<username>:<password>@example.com/packages/simple/
    PIP_TRUSTED_HOST: example.com
  
  extraPipPackages:
    - "my-internal-package==1.0.0"
```

<h3>Option 2 - embedded into container image (recommended)</h3>

This chart uses the official [apache/airflow](https://hub.docker.com/r/apache/airflow) images, consult airflow's official [docs about custom images](https://airflow.apache.org/docs/apache-airflow/2.0.1/production-deployment.html#production-container-images), you can extend the airflow container image with your pip packages.

For example, extending `airflow:2.0.1-python3.8` with the `torch` package:
```dockerfile
FROM apache/airflow:2.0.1-python3.8

# install your pip packages
RUN pip install torch~=1.8.0
```

Example values to use your `MY_REPO:MY_TAG` container image:
```yaml
airflow:
  image:
    repository: MY_REPO
    tag: MY_TAG
```

<hr>
</details>

### How to create airflow users? 
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - use plain-text</h3>

You can use the `airflow.users` value to create airflow users in a declarative way.

Example values to create `admin` (with "Admin" RBAC role) and `user` (with "User" RBAC role):
```yaml
airflow:
  users:
    - username: admin
      password: admin
      role: Admin
      email: admin@example.com
      firstName: admin
      lastName: admin
    - username: user
      password: user123
      ## TIP: `role` can be a single role or a list of roles
      role: 
        - User
        - Viewer
      email: user@example.com
      firstName: user
      lastName: user

  ## if we create a Deployment to perpetually sync `airflow.users`
  usersUpdate: true
```

<h3>Option 2 - use templates from Secrets/ConfigMaps</h3>

> 🟨 __Note__ 🟨
>
> If `airflow.usersUpdate = true`, the users which use `airflow.usersTemplates` will be updated in real-time, allowing tools like [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used.

You can use `airflow.usersTemplates` to extract string templates from keys in Secrets or Configmaps.

Example values to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in parts of the `admin` user:
```yaml
airflow:
  users:
    - username: admin
      password: ${ADMIN_PASSWORD}
      role: Admin
      email: ${ADMIN_EMAIL}
      firstName: admin
      lastName: admin
        
  ## bash-like templates to be used in `airflow.users`
  usersTemplates:
    ADMIN_PASSWORD:
      kind: secret
      name: my-secret
      key: password
    ADMIN_EMAIL:
      kind: configmap
      name: my-configmap
      key: email
        
  ## if we create a Deployment to perpetually sync `airflow.users`
  usersUpdate: true
```

<hr>
</details>

### How to authenticate airflow users with LDAP/OAUTH? 
<details>
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥 
> 
> If you set up LDAP/OAUTH, you should set `airflow.users = []` (and delete any previously created users)
> 
> The version of Flask-Builder installed might not be the latest, see [How to install extra pip packages?](#how-to-install-extra-pip-packages)

You can use the `web.webserverConfig.*` values to adjust the Flask-Appbuilder `webserver_config.py` file, read [Flask-builder's security docs](https://flask-appbuilder.readthedocs.io/en/latest/security.html) for further reference.

<h3>Option 1 - use LDAP</h3>

Example values to integrate with a typical Microsoft Active Directory using `AUTH_LDAP`:
```yaml
web:
  # WARNING: for production usage, create your own image with these packages installed rather than using `extraPipPackages`
  extraPipPackages:
    ## the following configs require Flask-AppBuilder 3.2.0 (or later)
    - "Flask-AppBuilder~=3.3.0"
    ## the following configs require python-ldap
    - "python-ldap~=3.3.1"

  webserverConfig:
    stringOverride: |-
      from airflow import configuration as conf
      from flask_appbuilder.security.manager import AUTH_LDAP

      SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')
      
      AUTH_TYPE = AUTH_LDAP
      AUTH_LDAP_SERVER = "ldap://ldap.example.com"
      AUTH_LDAP_USE_TLS = False
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING
      AUTH_LDAP_FIRSTNAME_FIELD = "givenName"
      AUTH_LDAP_LASTNAME_FIELD = "sn"
      AUTH_LDAP_EMAIL_FIELD = "mail"  # if null in LDAP, email is set to: "{username}@email.notfound"
      
      # bind username (for password validation)
      AUTH_LDAP_USERNAME_FORMAT = "uid=%s,ou=users,dc=example,dc=com"  # %s is replaced with the provided username
      # AUTH_LDAP_APPEND_DOMAIN = "example.com"  # bind usernames will look like: {USERNAME}@example.com
      
      # search configs
      AUTH_LDAP_SEARCH = "ou=users,dc=example,dc=com"  # the LDAP search base (if non-empty, a search will ALWAYS happen)
      AUTH_LDAP_UID_FIELD = "uid"  # the username field

      # a mapping from LDAP DN to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "cn=airflow_users,ou=groups,dc=example,dc=com": ["User"],
          "cn=airflow_admins,ou=groups,dc=example,dc=com": ["Admin"],
      }
      
      # the LDAP user attribute which has their role DNs
      AUTH_LDAP_GROUP_FIELD = "memberOf"
      
      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```

<h3>Option 2 - use OAUTH</h3>

Example values to integrate with Okta using `AUTH_OAUTH`:
```yaml
web:
  extraPipPackages:
    ## the following configs require Flask-AppBuilder 3.2.0 (or later)
    - "Flask-AppBuilder~=3.3.0"
    ## the following configs require Authlib
    - "Authlib~=0.15.3"

  webserverConfig:
    stringOverride: |-
      from airflow import configuration as conf
      from flask_appbuilder.security.manager import AUTH_OAUTH

      SQLALCHEMY_DATABASE_URI = conf.get('core', 'SQL_ALCHEMY_CONN')
      
      AUTH_TYPE = AUTH_OAUTH
      
      # registration configs
      AUTH_USER_REGISTRATION = True  # allow users who are not already in the FAB DB
      AUTH_USER_REGISTRATION_ROLE = "Public"  # this role will be given in addition to any AUTH_ROLES_MAPPING

      # the list of providers which the user can choose from
      OAUTH_PROVIDERS = [
          {
              'name': 'okta',
              'icon': 'fa-circle-o',
              'token_key': 'access_token',
              'remote_app': {
                  'client_id': 'OKTA_KEY',
                  'client_secret': 'OKTA_SECRET',
                  'api_base_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/',
                  'client_kwargs': {
                      'scope': 'openid profile email groups'
                  },
                  'access_token_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/token',
                  'authorize_url': 'https://OKTA_DOMAIN.okta.com/oauth2/v1/authorize',
              }
          }
      ]
      
      # a mapping from the values of `userinfo["role_keys"]` to a list of FAB roles
      AUTH_ROLES_MAPPING = {
          "FAB_USERS": ["User"],
          "FAB_ADMINS": ["Admin"],
      }

      # if we should replace ALL the user's roles each login, or only on registration
      AUTH_ROLES_SYNC_AT_LOGIN = True
      
      # force users to re-auth after 30min of inactivity (to keep roles in sync)
      PERMANENT_SESSION_LIFETIME = 1800
```

<hr>
</details>

### How to set a custom fernet encryption key? 
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - using the value</h3>

> 🟥 __Warning__ 🟥
>
> We strongly recommend that you DO NOT USE the default `airflow.fernetKey` in production.

You can set the fernet encryption key using the `airflow.fernetKey` value, which sets the `AIRFLOW__CORE__FERNET_KEY` environment variable.

Example values to define the fernet key with `airflow.fernetKey`:
```yaml
aiflow:
  fernetKey: "7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc="
```

<h3>Option 2 - using a secret (recommended)</h3>

You can set the fernet encryption key from a Kubernetes Secret by referencing it with the `airflow.extraEnv` value.

Example values to use the `value` key from the existing Secret `airflow-fernet-key`:
```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__CORE__FERNET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-fernet-key
          key: value
```

<h3>Option 3 - using `_CMD` or `_SECRET` configs</h3>

You can also set the fernet key by specifying either the `AIRFLOW__CORE__FERNET_KEY_CMD` or `AIRFLOW__CORE__FERNET_KEY_SECRET` environment variables.
Read about how the `_CMD` or `_SECRET` configs work in the ["Setting Configuration Options"](https://airflow.apache.org/docs/apache-airflow/stable/howto/set-config.html) section of the Airflow documentation.

Example values for using `AIRFLOW__CORE__FERNET_KEY_CMD`:

```yaml
airflow:
  ## WARNING: you must set `fernetKey` to "", otherwise it will take precedence
  fernetKey: ""

  ## NOTE: this is only an example, if your value lives in a Secret, you probably want to use "Option 2" above
  config:
    AIRFLOW__CORE__FERNET_KEY_CMD: "cat /opt/airflow/fernet-key/value"
      
  extraVolumeMounts:
    - name: fernet-key
      mountPath: /opt/airflow/fernet-key
      readOnly: true
      
  extraVolumes:
    - name: fernet-key
      secret:
        secretName: airflow-fernet-key
```

<hr>
</details>

### How to set a custom webserver secret_key?
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - using the value</h3>

> 🟥 __Warning__ 🟥
>
> We strongly recommend that you DO NOT USE the default `airflow.webserverSecretKey` in production.

You can set the webserver secret_key using the `airflow.webserverSecretKey` value, which sets the `AIRFLOW__WEBSERVER__SECRET_KEY` environment variable.

Example values to define the secret_key with `airflow.webserverSecretKey`:
```yaml
aiflow:
  webserverSecretKey: "THIS IS UNSAFE!"
```

<h3>Option 2 - using a secret (recommended)</h3>

You can set the webserver secret_key from a Kubernetes Secret by referencing it with the `airflow.extraEnv` value.

Example values to use the `value` key from the existing Secret `airflow-webserver-secret-key`:
```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__WEBSERVER__SECRET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-webserver-secret-key
          key: value
```

<h3>Option 3 - using `_CMD` or `_SECRET` configs</h3>

You can also set the webserver secret key by specifying either the `AIRFLOW__WEBSERVER__SECRET_KEY_CMD` or `AIRFLOW__WEBSERVER__SECRET_KEY_SECRET` environment variables. 
Read about how the `_CMD` or `_SECRET` configs work in the ["Setting Configuration Options"](https://airflow.apache.org/docs/apache-airflow/stable/howto/set-config.html) section of the Airflow documentation.

Example values for using `AIRFLOW__WEBSERVER__SECRET_KEY_CMD`:

```yaml
airflow:
  ## WARNING: you must set `webserverSecretKey` to "", otherwise it will take precedence
  webserverSecretKey: ""

  ## NOTE: this is only an example, if your value lives in a Secret, you probably want to use "Option 2" above
  config:
    AIRFLOW__WEBSERVER__SECRET_KEY_CMD: "cat /opt/airflow/webserver-secret-key/value"
      
  extraVolumeMounts:
    - name: webserver-secret-key
      mountPath: /opt/airflow/webserver-secret-key
      readOnly: true
      
  extraVolumes:
    - name: webserver-secret-key
      secret:
        secretName: airflow-webserver-secret-key
```

<hr>
</details>

### How to create airflow connections?
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - use plain-text</h3>

You can use the `airflow.connections` value to create airflow [Connections](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#connections) in a declarative way.

Example values to create connections called `my_aws`, `my_gcp`, `my_postgres`, and `my_ssh`:
```yaml
airflow: 
  connections:
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html
    - id: my_aws
      type: aws
      description: my AWS connection
      extra: |-
        { "aws_access_key_id": "XXXXXXXX",
          "aws_secret_access_key": "XXXXXXXX",
          "region_name":"eu-central-1" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-google/stable/connections/gcp.html
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      extra: |-
        { "extra__google_cloud_platform__keyfile_dict": "XXXXXXXX",
          "extra__google_cloud_platform__num_retries: "XXXXXXXX" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-postgres/stable/connections/postgres.html
    - id: my_postgres
      type: postgres
      description: my Postgres connection
      host: postgres.example.com
      port: 5432
      login: db_user
      password: db_pass
      schema: my_db
      extra: |-
        { "sslmode": "allow" }
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-ssh/stable/connections/ssh.html
    - id: my_ssh
      type: ssh
      description: my SSH connection
      host: ssh.example.com
      port: 22
      login: ssh_user
      password: ssh_pass
      extra: |-
        { "timeout": "15" }

  ## if we create a Deployment to perpetually sync `airflow.connections`
  connectionsUpdate: true
```

<h3>Option 2 - use templates from Secrets/ConfigMaps</h3>

> 🟨 __Note__ 🟨
>
> If `airflow.connectionsUpdate = true`, the connections which use `airflow.connectionsTemplates` will be updated in real-time, allowing tools like [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used.

You can use `airflow.connectionsTemplates` to extract string templates from keys in Secrets or Configmaps.

Example values to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in parts of the `my_aws` connection:
```yaml
airflow: 
  connections:
    - id: my_aws
      type: aws
      description: my AWS connection
      extra: |-
        { "aws_access_key_id": "${AWS_ACCESS_KEY_ID}",
          "aws_secret_access_key": "${AWS_ACCESS_KEY}",
          "region_name":"eu-central-1" }

  ## bash-like templates to be used in `airflow.connections`
  connectionsTemplates:
    AWS_ACCESS_KEY_ID:
      kind: configmap
      name: my-configmap
      key: username
    AWS_ACCESS_KEY:
      kind: secret
      name: my-secret
      key: password

  ## if we create a Deployment to perpetually sync `airflow.connections`
  connectionsUpdate: true
```

<hr>
</details>

### How to create airflow variables?
<details>
<summary>Expand</summary>
<hr>

<h3>Option 1 - use plain-text</h3>

You can use the `airflow.variables` value to create airflow [Variables](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#variables) in a declarative way.

Example values to create variables called `var_1`, `var_2`:
```yaml
airflow:
  variables:
    - key: "var_1"
      value: "my_value_1"
    - key: "var_2"
      value: "my_value_2"

  ## if we create a Deployment to perpetually sync `airflow.variables`
  variablesUpdate: true
```

<h3>Option 2 - use templates from Secrets/Configmaps</h3>

> 🟨 __Note__ 🟨
>
> If `airflow.variablesTemplates = true`, the connections which use `airflow.variablesTemplates` will be updated in real-time, allowing tools like [external-secrets](https://github.com/external-secrets/kubernetes-external-secrets) to be used.

You can use `airflow.variablesTemplates` to extract string templates from keys in Secrets or Configmaps.

Example values to use templates from `Secret/my-secret` and `ConfigMap/my-configmap` in the `var_1` and `var_2` variables:
```yaml
airflow:
  variables:
    - key: "var_1"
      value: "${MY_VALUE_1}"
    - key: "var_2"
      value: "${MY_VALUE_2}"

  ## bash-like templates to be used in `airflow.variables`
  variablesTemplates:
    MY_VALUE_1:
      kind: configmap
      name: my-configmap
      key: value1
    MY_VALUE_2:
      kind: secret
      name: my-secret
      key: value2

  ## if we create a Deployment to perpetually sync `airflow.variables`
  ##
  variablesUpdate: false
```

<hr>
</details>

### How to create airflow pools?
<details>
<summary>Expand</summary>
<hr>

You can use the `airflow.pools` value to create airflow [Pools](https://airflow.apache.org/docs/apache-airflow/stable/concepts.html#pools) in a declarative way.

Example values to create pools called `pool_1`, `pool_2`:
```yaml
airflow:
  pools:
    - name: "pool_1"
      description: "example pool with 5 slots"
      slots: 5
    - name: "pool_2"
      description: "example pool with 10 slots"
      slots: 10

  ## if we create a Deployment to perpetually sync `airflow.pools`
  poolsUpdate: true
```

<hr>
</details>

### How to set up celery worker autoscaling?
<details>
<summary>Expand</summary>
<hr>

> 🟨 __Note__ 🟨
> 
> This method of autoscaling is not ideal. There is not necessarily a link between RAM usage, and the number of pending tasks, meaning you could have a situation where your workers don't scale up despite having pending tasks.

The Airflow Celery Workers can be scaled using the [Horizontal Pod Autoscaler](https://kubernetes.io/docs/tasks/run-application/horizontal-pod-autoscale/), to enable autoscaling, you must set `workers.autoscaling.enabled=true`, then provide `workers.autoscaling.maxReplicas`.

Assume every task a worker executes consumes approximately `200Mi` memory, that means memory is a good metric for utilisation monitoring.
For a worker pod you can calculate it: `WORKER_CONCURRENCY * 200Mi`, so for `10 tasks` a worker will consume `~2Gi` of memory. 
In the following config if a worker consumes `80%` of `2Gi` (which will happen if it runs 9-10 tasks at the same time), an autoscaling event will be triggered, and a new worker will be added.
If you have many tasks in a queue, Kubernetes will keep adding workers until maxReplicas reached, in this case `16`.
```yaml
airflow:
  config:
    AIRFLOW__CELERY__WORKER_CONCURRENCY: 10

workers:
  # the initial/minimum number of workers
  replicas: 2

  resources:
    requests:
      memory: "2Gi"

  podDisruptionBudget:
    enabled: true
    ## prevents losing more than 20% of current worker task slots in a voluntary disruption
    maxUnavailable: "20%"

  autoscaling:
    enabled: true
    maxReplicas: 16
    metrics:
    - type: Resource
      resource:
        name: memory
        target:
          type: Utilization
          averageUtilization: 80

  celery:
    ## wait at most 9min for running tasks to complete before SIGTERM
    ## WARNING: 
    ## - some cloud cluster-autoscaler configs will not respect graceful termination 
    ##   longer than 10min, for example, Google Kubernetes Engine (GKE)
    gracefullTermination: true
    gracefullTerminationPeriod: 540

  ## how many seconds (after the 9min) to wait before SIGKILL
  terminationPeriod: 60

  logCleanup:
    resources:
      requests:
        ## IMPORTANT! for autoscaling to work with logCleanup
        memory: "64Mi"

dags:
  gitSync:
    resources:
      requests:
        ## IMPORTANT! for autoscaling to work with gitSync
        memory: "64Mi"
```

<hr>
</details>

### How to persist airflow logs?
<details>
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥 
> 
> For production, you should persist logs in a production deployment using one of these methods.<br>
> By default, logs are stored within the container's filesystem, therefore any restart of the pod will wipe your DAG logs.

<h3>Option 1a - PersistentVolumeClaim (chart-managed)</h3>

Example values to create a PVC with the cluster-default `storageClass` and 1Gi initial `size`:
```yaml
airflow:
  defaultSecurityContext:
    ## sets the filesystem owner group of files/folders in mounted volumes
    ## this does NOT give root permissions to Pods, only the "root" group
    fsGroup: 0

scheduler:
  logCleanup:
    ## scheduler log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

workers:
  logCleanup:
    ## workers log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

logs:
  persistence:
    enabled: true
    storageClass: "" ## empty string means cluster-default
    accessMode: ReadWriteMany
    size: 1Gi
```

<h3>Option 1b - PersistentVolumeClaim (existing / user-managed)</h3>

> 🟨 __Note__ 🟨
>
> Your `logs.persistence.existingClaim` PVC must support `ReadWriteMany` for `accessMode`

Example values to use an existing PVC called `my-logs-pvc`:

```yaml
airflow:
  defaultSecurityContext:
    ## sets the filesystem owner group of files/folders in mounted volumes
    ## this does NOT give root permissions to Pods, only the "root" group
    fsGroup: 0

scheduler:
  logCleanup:
    ## scheduler log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

workers:
  logCleanup:
    ## workers log-cleanup must be disabled if `logs.persistence.enabled` is `true`
    enabled: false

logs:
  persistence:
    enabled: true
    existingClaim: my-logs-pvc
    accessMode: ReadWriteMany
```

<h3>Option 2a - Remote S3 Bucket (recommended on AWS)</h3>

Example values to use a remote S3 bucket for logging, with an `airflow.connection` called `my_aws` for authorization:
```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_aws"
    
  connections:
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-amazon/stable/connections/aws.html
    - id: my_aws
      type: aws
      description: my AWS connection
      extra: |-
        { "aws_access_key_id": "XXXXXXXX",
          "aws_secret_access_key": "XXXXXXXX",
          "region_name":"eu-central-1" }
```

Example values to use a remote S3 bucket for logging, with [EKS - IAM Roles for Service Accounts](https://docs.aws.amazon.com/eks/latest/userguide/iam-roles-for-service-accounts.html) for authorization:
```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "s3://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "aws_default"

serviceAccount:
  annotations:
    eks.amazonaws.com/role-arn: "arn:aws:iam::XXXXXXXXXX:role/<<MY-ROLE-NAME>>"
```

<h3>Option 2b - Remote GCS Bucket (recommended on GCP)</h3>

Example values to use a remote GCS bucket for logging, with an `airflow.connection` called `my_gcp` for authorization:
```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "gs://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "my_gcp"
    
  connections:
    ## see docs: https://airflow.apache.org/docs/apache-airflow-providers-google/stable/connections/gcp.html
    - id: my_gcp
      type: google_cloud_platform
      description: my GCP connection
      extra: |-
        { "extra__google_cloud_platform__keyfile_dict": "XXXXXXXX",
          "extra__google_cloud_platform__num_retries": "5" }
```

Example values to use a remote GCS bucket for logging, with [GKE - Workload Identity](https://cloud.google.com/kubernetes-engine/docs/how-to/workload-identity) for authorization:
```yaml
airflow:
  config:
    AIRFLOW__LOGGING__REMOTE_LOGGING: "True"
    AIRFLOW__LOGGING__REMOTE_BASE_LOG_FOLDER: "gs://<<MY-BUCKET-NAME>>/airflow/logs"
    AIRFLOW__LOGGING__REMOTE_LOG_CONN_ID: "google_cloud_default"

serviceAccount:
  annotations:
    iam.gke.io/gcp-service-account: "<<MY-ROLE-NAME>>@<<MY-PROJECT-NAME>>.iam.gserviceaccount.com"
```

<hr>
</details>

### How to configure the scheduler liveness probe?
<details>
<summary>Expand</summary>
<hr>

<h3>Scheduler "Heartbeat Check"</h3>

The chart includes a [Kubernetes Liveness Probe](https://kubernetes.io/docs/tasks/configure-pod-container/configure-liveness-readiness-startup-probes/) 
for each airflow scheduler which regularly queries the Airflow Metadata Database to ensure the scheduler is ["healthy"](https://airflow.apache.org/docs/apache-airflow/stable/logging-monitoring/check-health.html).

A scheduler is "healthy" if it has had a "heartbeat" in the last `AIRFLOW__SCHEDULER__SCHEDULER_HEALTH_CHECK_THRESHOLD` seconds.
Each scheduler will perform a "heartbeat" every `AIRFLOW__SCHEDULER__SCHEDULER_HEARTBEAT_SEC` seconds by updating the `latest_heartbeat` of its `SchedulerJob` in the Airflow Metadata `jobs` table.

> 🟥 __Warning__ 🟥
>
> A scheduler can have a "heartbeat" but be deadlocked such that it's unable to schedule new tasks,
> we provide the `scheduler.livenessProbe.taskCreationCheck.*` values to automatically restart the scheduler in these cases.
>
> https://github.com/apache/airflow/issues/7935 - patched in airflow `2.0.2`<br>
> https://github.com/apache/airflow/issues/15938 - patched in airflow `2.1.1`

By default, the chart runs a liveness probe every __30 seconds__ (`periodSeconds`), and will restart a scheduler if __5 probe failures__ (`failureThreshold`) occur in a row.
This means a scheduler must be unhealthy for at least `30 x 5 = 150` seconds before Kubernetes will automatically restart a scheduler Pod.

Here is an overview of the `scheduler.livenessProbe.*` values:

```yaml
scheduler:
  livenessProbe:
    enabled: true
    
    ## number of seconds to wait after a scheduler container starts before running its first probe
    ## NOTE: schedulers take a few seconds to actually start
    initialDelaySeconds: 10
    
    ## number of seconds to wait between each probe
    periodSeconds: 30
    
    ## maximum number of seconds that a probe can take before timing out
    ## WARNING: if your database is very slow, you may need to increase this value to prevent invalid scheduler restarts
    timeoutSeconds: 60
    
    ## maximum number of consecutive probe failures, after which the scheduler will be restarted
    ## NOTE: a "failure" could be any of:
    ##  1. the probe takes more than `timeoutSeconds`
    ##  2. the probe detects the scheduler as "unhealthy"
    ##  3. the probe "task creation check" fails
    failureThreshold: 5
```

<h3>Scheduler "Task Creation Check"</h3>

The liveness probe can additionally check if the Scheduler is creating new [tasks](https://airflow.apache.org/docs/apache-airflow/stable/concepts/tasks.html) as an indication of its health. 
This check works by ensuring that the most recent `LocalTaskJob` had a `start_date` no more than `scheduler.livenessProbe.taskCreationCheck.thresholdSeconds` seconds ago.

> 🟦 __Tip__ 🟦
>
> The "Task Creation Check" is currently disabled by default, it can be enabled with `scheduler.livenessProbe.taskCreationCheck.enabled`.

Here is an overview of the `scheduler.livenessProbe.taskCreationCheck.*` values:

```yaml
scheduler:
  livenessProbe:
    enabled: true
    ...
    
    taskCreationCheck:
      ## if the task creation check is enabled
      enabled: true

      ## the maximum number of seconds since the start_date of the most recent LocalTaskJob
      ## WARNING: must be AT LEAST equal to your shortest DAG schedule_interval
      ## WARNING: DummyOperator tasks will NOT be seen by this probe
      thresholdSeconds: 300
```

You might use the following `canary_dag` DAG definition to run a small task every __300 seconds__ (5 minutes):

```python
from datetime import datetime, timedelta
from airflow import DAG

# import using try/except to support both airflow 1 and 2
try:
    from airflow.operators.bash import BashOperator
except ModuleNotFoundError:
    from airflow.operators.bash_operator import BashOperator

dag = DAG(
    dag_id="canary_dag",
    default_args={
        "owner": "airflow",
    },
    schedule_interval="*/5 * * * *",
    start_date=datetime(2022, 1, 1),
    dagrun_timeout=timedelta(minutes=5),
    is_paused_upon_creation=False,
    catchup=False,
)

# WARNING: while `DummyOperator` would use less resources, the check can't see those tasks 
#          as they don't create LocalTaskJob instances
task = BashOperator(
    task_id="canary_task",
    bash_command="echo 'Hello World!'",
    dag=dag,
)
```

<hr>
</details>

## FAQ - Databases

> __Frequently asked questions related to database configs__

### How to use the embedded Postgres?
<details>
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥 
> 
> The embedded Postgres is NOT SUITABLE for production, you should follow [How to use an external database?](#how-to-use-an-external-database)

> 🟨 __Note__ 🟨
>
> If `pgbouncer.enabled=true` (the default), we will deploy [PgBouncer](https://www.pgbouncer.org/) to pool connections to your external database 

The embedded Postgres database has an insecure username/password by default, you should create secure credentials before using it.

For example, to create the required Kubernetes Secrets:
```sh
# set postgress password
kubectl create secret generic \
  airflow-postgresql \
  --from-literal=postgresql-password=$(openssl rand -base64 13) \
  --namespace my-airflow-namespace

# set redis password
kubectl create secret generic \
  airflow-redis \
  --from-literal=redis-password=$(openssl rand -base64 13) \
  --namespace my-airflow-namespace
```

Example values to use those secrets:
```yaml
postgresql:
  existingSecret: airflow-postgresql

redis:
  existingSecret: airflow-redis
```

<hr>
</details>

### How to use an external database?
<details>
<summary>Expand</summary>
<hr>

> 🟥 __Warning__ 🟥
>
> We __STRONGLY RECOMMEND__ that all production deployments of Airflow use an external database (not managed by this chart).

When compared with the Postgres that is embedded in this chart, an external database comes with many benefits:

1. The embedded Postgres version is usually very outdated, so is susceptible to critical security bugs
2. The embedded database may not scale to your performance requirements _(NOTE: every airflow task creates database connections)_
3. An external database will likely achieve higher uptime _(NOTE: no airflow tasks will run if your database is down)_
4. An external database can be configured with backups and disaster recovery

Commonly, people use the managed PostgreSQL service from their cloud vendor to provision an external database:

Cloud Platform | Service Name
--- | ---
Amazon Web Services | [Amazon RDS for PostgreSQL](https://aws.amazon.com/rds/postgresql/)
Microsoft Azure | [Azure Database for PostgreSQL](https://azure.microsoft.com/en-au/services/postgresql/) 
Google Cloud | [Cloud SQL for PostgreSQL](https://cloud.google.com/sql/docs/postgres)
Alibaba Cloud | [ApsaraDB RDS for PostgreSQL](https://www.alibabacloud.com/product/apsaradb-for-rds-postgresql)
IBM Cloud | [IBM Cloud® Databases for PostgreSQL](https://cloud.ibm.com/docs/databases-for-postgresql)

<h3>Option 1 - Postgres</h3>

> 🟨 __Note__ 🟨
>
> By default, this chart deploys [PgBouncer](https://www.pgbouncer.org/) to pool db connections and reduce the load from large numbers of airflow tasks.
>
> You may disable PgBouncer by setting `pgbouncer.enabled` to `false`.

Example values for an external Postgres database, with an existing `airflow_cluster1` database:
```yaml
postgresql:
  ## to use the external db, the embedded one must be disabled
  enabled: false

## for full list of PgBouncer configs, see values.yaml
pgbouncer:
  enabled: true

  ## WARNING: you must set "scram-sha-256" if using Azure PostgreSQL (single server mode)
  authType: md5

  serverSSL:
    ## WARNING: you must set "verify-ca" if using Azure PostgreSQL
    mode: prefer

externalDatabase:
  type: postgres
  
  host: postgres.example.org
  port: 5432
  
  ## the schema which will contain the airflow tables
  database: airflow_cluster1

  ## (username - option 1) a plain-text helm value
  user: my_airflow_user
  
  ## (username - option 2) a Kubernetes secret in your airflow namespace
  #userSecret: "airflow-cluster1-database-credentials"
  #userSecretKey: "username"

  ## (password - option 1) a plain-text helm value
  password: my_airflow_password

  ## (password - option 2) a Kubernetes secret in your airflow namespace
  #passwordSecret: "airflow-cluster1-database-credentials"
  #passwordSecretKey: "password"

  ## use this for any extra connection-string settings, e.g. ?sslmode=disable
  properties: ""
```

<h3>Option 2 - MySQL</h3>

> 🟨 __Note__ 🟨 
> 
> You must set `explicit_defaults_for_timestamp=1` in your MySQL instance, [see here](https://airflow.apache.org/docs/stable/howto/initialize-database.html)

Example values for an external MySQL database, with an existing `airflow_cluster1` database:
```yaml
postgresql:
  ## to use the external db, the embedded one must be disabled
  enabled: false

pgbouncer:
  ## pgbouncer is automatically disabled if `externalDatabase.type` is `mysql`
  #enabled: false

externalDatabase:
  type: mysql
  
  host: mysql.example.org
  port: 3306

  ## the database which will contain the airflow tables
  database: airflow_cluster1

  ## (username - option 1) a plain-text helm value
  user: my_airflow_user

  ## (username - option 2) a Kubernetes secret in your airflow namespace
  #userSecret: "airflow-cluster1-database-credentials"
  #userSecretKey: "username"

  ## (password - option 1) a plain-text helm value
  password: my_airflow_password

  ## (password - option 2) a Kubernetes secret in your airflow namespace
  #passwordSecret: "airflow-cluster1-database-credentials"
  #passwordSecretKey: "password"

  ## use this for any extra connection-string settings, e.g. ?useSSL=false
  properties: ""
```

<hr>
</details>

### How to use an external redis?
<details>
<summary>Expand</summary>
<hr>

Example values for an external redis with ssl enabled:
```yaml
redis:
  enabled: false

externalRedis:
  host: "example.redis.cache.windows.net"
  port: 6380
  
  ## the redis database-number that airflow will use
  databaseNumber: 1

  ## (option 1 - password) a plain-text helm value
  password: my_airflow_password

  ## (option 2 - password) a Kubernetes secret in your airflow namespace
  #passwordSecret: "airflow-cluster1-redis-credentials"
  #passwordSecretKey: "password"

  ## use this for any extra connection-string settings
  properties: "?ssl_cert_reqs=CERT_OPTIONAL"
```

<hr>
</details>

## FAQ - Kubernetes

> __Frequently asked questions related to kubernetes configs__

### How to mount ConfigMaps/Secrets as environment variables?
<details>
<summary>Expand</summary>
<hr>

> 🟨 __Note__ 🟨 
> 
> This method can be used to pass sensitive configs to Airflow

You can use the `airflow.extraEnv` value to mount extra environment variables with the same structure as [EnvVar in ContainerSpec](https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#envvar-v1-core).

Example values to use the `value` key from the existing Secret `airflow-fernet-key` to define `AIRFLOW__CORE__FERNET_KEY`:
```yaml
airflow:
  extraEnv:
    - name: AIRFLOW__CORE__FERNET_KEY
      valueFrom:
        secretKeyRef:
          name: airflow-fernet-key
          key: value
```

<hr>
</details>

### How to mount Secrets/Configmaps as files on workers?
<details>
<summary>Expand</summary>
<hr>

You can use the `workers.extraVolumeMounts` and `workers.extraVolumes` values to mount Secretes as files.

For example, if the Secret `redshift-creds` already exist, and has keys called `user` and `password`:
```yaml
workers:
  extraVolumeMounts:
    - name: redshift-creds
      mountPath: /opt/airflow/secrets/redshift-creds
      readOnly: true

  extraVolumes:
    - name: redshift-creds
      secret:
        secretName: redshift-creds
```

You could then read the `/opt/airflow/secrets/redshift-creds` files from within a DAG Python function:
```python
from pathlib import Path
redis_user = Path("/opt/airflow/secrets/redshift-creds/user").read_text().strip()
redis_password = Path("/opt/airflow/secrets/redshift-creds/password").read_text().strip()
```

To create the `redshift-creds` Secret, you could use:
```console
kubectl create secret generic \
  redshift-creds \
  --from-literal=user=MY_REDSHIFT_USERNAME \
  --from-literal=password=MY_REDSHIFT_PASSWORD \
  --namespace my-airflow-namespace
```

<hr>
</details>

### How to set up an Ingress?
<details>
<summary>Expand</summary>
<hr>

The chart provides the `ingress.*` values for deploying a Kubernetes Ingress to allow access to airflow outside the cluster.

Consider the situation where you already have something hosted at the root of your domain, you might want to place airflow under a URL-prefix:
- http://example.com/airflow/
- http://example.com/airflow/flower

In this example, you would set these values, assuming you have an Ingress Controller with an IngressClass named "nginx" deployed:
```yaml
airflow:
  config: 
    AIRFLOW__WEBSERVER__BASE_URL: "http://example.com/airflow/"
    AIRFLOW__CELERY__FLOWER_URL_PREFIX: "/airflow/flower"

ingress:
  enabled: true
  
  ## WARNING: set as "networking.k8s.io/v1beta1" for Kubernetes 1.18 and earlier
  apiVersion: networking.k8s.io/v1
  
  ## airflow webserver ingress configs
  web:
    annotations: {}
    host: "example.com"
    path: "/airflow"
    ## WARNING: requires Kubernetes 1.18 or later, use "kubernetes.io/ingress.class" annotation for older versions
    ingressClassName: "nginx"
    
  ## flower ingress configs
  flower:
    annotations: {}
    host: "example.com"
    path: "/airflow/flower"
    ## WARNING: requires Kubernetes 1.18 or later, use "kubernetes.io/ingress.class" annotation for older versions
    ingressClassName: "nginx"
```

We expose the `ingress.web.precedingPaths` and `ingress.web.succeedingPaths` values, which are __before__ and __after__ the default path respectively.

> 🟦 __Tip__ 🟦 
> 
> A common use-case is [enabling SSL with the aws-alb-ingress-controller](https://kubernetes-sigs.github.io/aws-load-balancer-controller/v2.1/guide/tasks/ssl_redirect/), which needs a redirect path to be hit before the airflow-webserver one

For example, setting `ingress.web.precedingPaths` for an aws-alb-ingress-controller with SSL:
```yaml
ingress:
  web:
    precedingPaths:
      - path: "/*"
        serviceName: "ssl-redirect"
        servicePort: "use-annotation"
```

<hr>
</details>

### How to use Pod affinity, nodeSelector, and tolerations?
<details>
<summary>Expand</summary>
<hr>

If your environment needs to use Pod [affinity](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#affinity-and-anti-affinity), [nodeSelector](https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector), or [tolerations](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/), we provide many values that allow fine-grained control over the Pod definitions.

To set affinity, nodeSelector, and tolerations for all airflow Pods, you can use the `airflow.{defaultNodeSelector,defaultAffinity,defaultTolerations}` values:
```yaml
airflow:
  ## https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodeselector
  defaultNodeSelector: {}
    # my_node_label_1: value1
    # my_node_label_2: value2

  ## https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#affinity-v1-core
  defaultAffinity: {}
    # podAffinity:
    #   requiredDuringSchedulingIgnoredDuringExecution:
    #     - labelSelector:
    #         matchExpressions:
    #           - key: security
    #             operator: In
    #             values:
    #               - S1
    #       topologyKey: topology.kubernetes.io/zone
    # podAntiAffinity:
    #   preferredDuringSchedulingIgnoredDuringExecution:
    #     - weight: 100
    #       podAffinityTerm:
    #         labelSelector:
    #           matchExpressions:
    #             - key: security
    #               operator: In
    #               values:
    #                 - S2
    #         topologyKey: topology.kubernetes.io/zone

  ## https://kubernetes.io/docs/reference/generated/kubernetes-api/v1.20/#toleration-v1-core
  defaultTolerations: []
    # - key: "key1"
    #   operator: "Exists"
    #   effect: "NoSchedule"
    # - key: "key2"
    #   operator: "Exists"
    #   effect: "NoSchedule"

## if using the embedded postgres chart, you will also need to define these
postgresql:
  master:
    nodeSelector: {}
    affinity: {}
    tolerations: []

## if using the embedded redis chart, you will also need to define these
redis:
  master:
    nodeSelector: {}
    affinity: {}
    tolerations: []
```

The `airflow.{defaultNodeSelector,defaultAffinity,defaultTolerations}` values are overridden by the per-resource values like `scheduler.{nodeSelector,affinity,tolerations}`:
```yaml
airflow:
  ## airflow KubernetesExecutor pod_template
  kubernetesPodTemplate:
    nodeSelector: {}
    affinity: {}
    tolerations: []

  ## sync deployments
  sync:
    nodeSelector: {}
    affinity: {}
    tolerations: []

## airflow schedulers
scheduler:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow webserver
web:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow workers
workers:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow triggerer
triggerer:
  nodeSelector: {}
  affinity: {}
  tolerations: []

## airflow workers
flower:
  nodeSelector: {}
  affinity: {}
  tolerations: []
```

<hr>
</details>

### How to integrate airflow with Prometheus?
<details>
<summary>Expand</summary>
<hr>

To be able to expose Airflow metrics to Prometheus you will need install a plugin, one option is [epoch8/airflow-exporter](https://github.com/epoch8/airflow-exporter) which exports DAG and task metrics from Airflow.

A [ServiceMonitor](https://github.com/prometheus-operator/prometheus-operator/blob/master/Documentation/api.md#servicemonitor) is a resource introduced by the [Prometheus Operator](https://github.com/prometheus-operator/prometheus-operator), ror more information, see the `serviceMonitor` section of `values.yaml`.

<hr>
</details>

### How to add extra manifests?
<details>
<summary>Expand</summary>
<hr>

You may use the `extraManifests` value to specify a list of extra Kubernetes manifests that will be deployed alongside the chart.

> 🟦 __Tip__ 🟦 
> 
> [Helm templates](https://helm.sh/docs/chart_template_guide/functions_and_pipelines/) within these strings will be rendered

Example values to create a `Secret` for database credentials: _(__WARNING:__ store custom values securely if used)_
```yaml
extraManifests:
  - |
    apiVersion: v1
    kind: Secret
    metadata:
      name: airflow-postgres-credentials
    data:
      postgresql-password: {{ `password1` | b64enc | quote }}
```

Example values to create a `Deployment` for a [busybox](https://busybox.net/) container:
```yaml
extraManifests:
  - |
    apiVersion: apps/v1
    kind: Deployment
    metadata:
      name: {{ include "airflow.fullname" . }}-busybox
      labels:
        app: {{ include "airflow.labels.app" . }}
        component: busybox
        chart: {{ include "airflow.labels.chart" . }}
        release: {{ .Release.Name }}
        heritage: {{ .Release.Service }}
    spec:
      replicas: 1
      selector:
        matchLabels:
          app: {{ include "airflow.labels.app" . }}
          component: busybox
          release: {{ .Release.Name }}
      template:
        metadata:
          labels:
            app: {{ include "airflow.labels.app" . }}
            component: busybox
            release: {{ .Release.Name }}
        spec:
          containers:
            - name: busybox
              image: busybox:1.35
              command:
                - "/bin/sh"
                - "-c"
              args:
                - |
                  ## to break the infinite loop when we receive SIGTERM
                  trap "exit 0" SIGTERM;
                  ## keep the container running (so people can `kubectl exec -it` into it)
                  while true; do
                    echo "I am alive...";
                    sleep 30;
                  done
```

<hr>
</details>

## Values Reference

> __Values provided by this chart (for more info see [values.yaml](values.yaml))__

### `airflow.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`airflow.legacyCommands` | if we use legacy 1.10 airflow commands | `false`
`airflow.image.*` | configs for the airflow container image | `<see values.yaml>`
`airflow.executor` | the airflow executor type to use | `CeleryExecutor`
`airflow.fernetKey` | the fernet encryption key (sets `AIRFLOW__CORE__FERNET_KEY`) | `7T512UXSSmBOkpWimFHIVb8jK6lfmSAvx4mO6Arehnc=`
`airflow.webserverSecretKey` | the secret_key for flask (sets `AIRFLOW__WEBSERVER__SECRET_KEY`) | `THIS IS UNSAFE!`
`airflow.config` | environment variables for airflow configs | `{}`
`airflow.users` | a list of users to create | `<see values.yaml>`
`airflow.usersTemplates` | bash-like templates to be used in `airflow.users` | `<see values.yaml>`
`airflow.usersUpdate` | if we create a Deployment to perpetually sync `airflow.users` | `true`
`airflow.connections` | a list airflow connections to create | `<see values.yaml>`
`airflow.connectionsTemplates` | bash-like templates to be used in `airflow.connections` | `<see values.yaml>`
`airflow.connectionsUpdate` | if we create a Deployment to perpetually sync `airflow.connections` | `true`
`airflow.variables` | a list airflow variables to create | `<see values.yaml>`
`airflow.variablesTemplates` | bash-like templates to be used in `airflow.variables` | `<see values.yaml>`
`airflow.variablesUpdate` | if we create a Deployment to perpetually sync `airflow.variables` | `true`
`airflow.pools` | a list airflow pools to create | `<see values.yaml>`
`airflow.poolsUpdate` | if we create a Deployment to perpetually sync `airflow.pools` | `true`
`airflow.defaultNodeSelector` | default nodeSelector for airflow Pods (is overridden by pod-specific values) | `{}`
`airflow.defaultAffinity` | default affinity configs for airflow Pods (is overridden by pod-specific values) | `{}`
`airflow.defaultTolerations` | default toleration configs for airflow Pods (is overridden by pod-specific values) | `[]`
`airflow.defaultSecurityContext` | default securityContext configs for Pods (is overridden by pod-specific values) | `{fsGroup: 0}`
`airflow.podAnnotations` | extra annotations for airflow Pods | `{}`
`airflow.extraPipPackages` | extra pip packages to install in airflow Pods | `[]`
`airflow.extraEnv` | extra environment variables for the airflow Pods | `[]`
`airflow.extraContainers` | extra containers for the airflow Pods | `[]`
`airflow.extraVolumeMounts` | extra VolumeMounts for the airflow Pods | `[]`
`airflow.extraVolumes` | extra Volumes for the airflow Pods | `[]`
`airflow.clusterDomain` | kubernetes cluster domain name | `cluster.local`
`airflow.localSettings.*` | airflow_local_settings.py | `<see values.yaml>`
`airflow.kubernetesPodTemplate.*` | pod_template.yaml | `<see values.yaml>`
`airflow.dbMigrations.*` | db-migrations Deployment | `<see values.yaml>`
`airflow.sync.*` | Sync Deployments | `<see values.yaml>`

<hr>
</details>

### `scheduler.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`scheduler.replicas` | the number of scheduler Pods to run | `1`
`scheduler.resources` | resource requests/limits for the scheduler Pods | `{}`
`scheduler.nodeSelector` | the nodeSelector configs for the scheduler Pods | `{}`
`scheduler.affinity` | the affinity configs for the scheduler Pods | `{}`
`scheduler.tolerations` | the toleration configs for the scheduler Pods | `[]`
`scheduler.securityContext` | the security context for the scheduler Pods | `{}`
`scheduler.labels` | labels for the scheduler Deployment | `{}`
`scheduler.podLabels` | Pod labels for the scheduler Deployment | `{}`
`scheduler.annotations` | annotations for the scheduler Deployment | `{}`
`scheduler.podAnnotations` | Pod annotations for the scheduler Deployment | `{}`
`scheduler.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`scheduler.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the scheduler | `<see values.yaml>`
`scheduler.logCleanup.*` | configs for the log-cleanup sidecar of the scheduler | `<see values.yaml>`
`scheduler.numRuns` | the value of the `airflow --num_runs` parameter used to run the airflow scheduler | `-1`
`scheduler.extraPipPackages` | extra pip packages to install in the scheduler Pods | `[]`
`scheduler.extraVolumeMounts` | extra VolumeMounts for the scheduler Pods | `[]`
`scheduler.extraVolumes` | extra Volumes for the scheduler Pods | `[]`
`scheduler.livenessProbe.*` | configs for the scheduler Pods' liveness probe | `<see values.yaml>`
`scheduler.extraInitContainers` | extra init containers to run in the scheduler Pods | `[]`

<hr>
</details>

### `web.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`web.webserverConfig.*` | configs to generate webserver_config.py | `<see values.yaml>`
`web.replicas` | the number of web Pods to run | `1`
`web.resources` | resource requests/limits for the airflow web pods | `{}`
`web.nodeSelector` | the number of web Pods to run | `{}`
`web.affinity` | the affinity configs for the web Pods | `{}`
`web.tolerations` | the toleration configs for the web Pods | `[]`
`web.securityContext` | the security context for the web Pods | `{}`
`web.labels` | labels for the web Deployment | `{}`
`web.podLabels` | Pod labels for the web Deployment | `{}`
`web.annotations` | annotations for the web Deployment | `{}`
`web.podAnnotations` | Pod annotations for the web Deployment | `{}`
`web.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`web.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the web Deployment | `<see values.yaml>`
`web.service.*` | configs for the Service of the web pods | `<see values.yaml>`
`web.readinessProbe.*` | configs for the web Pods' readiness probe | `<see values.yaml>`
`web.livenessProbe.*` | configs for the web Pods' liveness probe | `<see values.yaml>`
`web.extraPipPackages` | extra pip packages to install in the web Pods | `[]`
`web.extraVolumeMounts` | extra VolumeMounts for the web Pods | `[]`
`web.extraVolumes` | extra Volumes for the web Pods | `[]`

<hr>
</details>

### `workers.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`workers.enabled` | if the airflow workers StatefulSet should be deployed | `true`
`workers.replicas` | the number of workers Pods to run | `1`
`workers.resources` | resource requests/limits for the airflow worker Pods | `{}`
`workers.nodeSelector` | the nodeSelector configs for the worker Pods | `{}`
`workers.affinity` | the affinity configs for the worker Pods | `{}`
`workers.tolerations` | the toleration configs for the worker Pods | `[]`
`workers.securityContext` | the security context for the worker Pods | `{}`
`workers.labels` | labels for the worker StatefulSet | `{}`
`workers.podLabels` | Pod labels for the worker StatefulSet | `{}`
`workers.annotations` | annotations for the worker StatefulSet | `{}`
`workers.podAnnotations` | Pod annotations for the worker StatefulSet | `{}`
`workers.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`workers.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the worker StatefulSet | `<see values.yaml>`
`workers.autoscaling.*` | configs for the HorizontalPodAutoscaler of the worker Pods | `<see values.yaml>`
`workers.celery.*` | configs for the celery worker Pods | `<see values.yaml>`
`workers.terminationPeriod` | how many seconds to wait after SIGTERM before SIGKILL of the celery worker | `60`
`workers.logCleanup.*` | configs for the log-cleanup sidecar of the worker Pods | `<see values.yaml>`
`workers.extraPipPackages` | extra pip packages to install in the worker Pods | `[]`
`workers.extraVolumeMounts` | extra VolumeMounts for the worker Pods | `[]`
`workers.extraVolumes` | extra Volumes for the worker Pods | `[]`

<hr>
</details>

### `triggerer.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`triggerer.enabled` | if the triggerer should be deployed | `true`
`triggerer.replicas` | the number of triggerer Pods to run | `1`
`triggerer.resources` | resource requests/limits for the airflow triggerer Pods | `{}`
`triggerer.nodeSelector` | the nodeSelector configs for the triggerer Pods | `{}`
`triggerer.affinity` | the affinity configs for the triggerer Pods | `{}`
`triggerer.tolerations` | the toleration configs for the triggerer Pods | `[]`
`triggerer.securityContext` | the security context for the triggerer Pods | `{}`
`triggerer.labels` | labels for the triggerer Deployment | `{}`
`triggerer.podLabels` | Pod labels for the triggerer Deployment | `{}`
`triggerer.annotations` | annotations for the triggerer Deployment | `{}`
`triggerer.podAnnotations` | Pod annotations for the triggerer Deployment | `{}`
`triggerer.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`triggerer.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the triggerer Deployment | `<see values.yaml>`
`triggerer.capacity` | maximum number of triggers each triggerer will run at once (sets `AIRFLOW__TRIGGERER__DEFAULT_CAPACITY`) | `1000`
`triggerer.livenessProbe.*` | liveness probe for the triggerer Pods | `<see values.yaml>`
`triggerer.extraPipPackages` | extra pip packages to install in the triggerer Pods | `[]`
`triggerer.extraVolumeMounts` | extra VolumeMounts for the triggerer Pods | `[]`
`triggerer.extraVolumes` | extra Volumes for the triggerer Pods | `[]`

<hr>
</details>

### `flower.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`flower.enabled` | if the Flower UI should be deployed | `true`
`flower.resources` | resource requests/limits for the flower Pods | `{}`
`flower.nodeSelector` | the nodeSelector configs for the flower Pods | `{}`
`flower.affinity` | the affinity configs for the flower Pods | `{}`
`flower.tolerations` | the toleration configs for the flower Pods | `[]`
`flower.securityContext` | the security context for the flower Pods | `{}`
`flower.labels` | labels for the flower Deployment | `{}`
`flower.podLabels` | Pod labels for the flower Deployment | `{}`
`flower.annotations` | annotations for the flower Deployment | `{}`
`flower.podAnnotations` | Pod annotations for the flower Deployment | `{}`
`flower.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`flower.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the flower Deployment | `<see values.yaml>`
`flower.basicAuthSecret` | the name of a pre-created secret containing the basic authentication value for flower | `""`
`flower.basicAuthSecretKey` | the key within `flower.basicAuthSecret` containing the basic authentication string | `""`
`flower.service.*` | configs for the Service of the flower Pods | `<see values.yaml>`
`flower.extraPipPackages` | extra pip packages to install in the flower Pod | `[]`
`flower.extraVolumeMounts` | extra VolumeMounts for the flower Pods | `[]`
`flower.extraVolumes` | extra Volumes for the flower Pods | `[]`

<hr>
</details>

### `logs.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`logs.path` | the airflow logs folder | `/opt/airflow/logs`
`logs.persistence.*` | configs for the logs PVC | `<see values.yaml>`

<hr>
</details>

### `dags.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`dags.path` | the airflow dags folder | `/opt/airflow/dags`
`dags.persistence.*` | configs for the dags PVC | `<see values.yaml>`
`dags.gitSync.*` | configs for the git-sync sidecar  | `<see values.yaml>`

<hr>
</details>

### `ingress.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`ingress.enabled` | if we should deploy Ingress resources | `false`
`ingress.apiVersion` | the `apiVersion` to use for Ingress resources | `networking.k8s.io/v1`
`ingress.web.*` | configs for the Ingress of the web Service | `<see values.yaml>`
`ingress.flower.*` | configs for the Ingress of the flower Service | `<see values.yaml>`

<hr>
</details>

### `rbac.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`rbac.create` | if Kubernetes RBAC resources are created | `true`
`rbac.events` | if the created RBAR role has GET/LIST access to Event resources | `false`

<hr>
</details>

### `serviceAccount.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`serviceAccount.create` | if a Kubernetes ServiceAccount is created | `true`
`serviceAccount.name` | the name of the ServiceAccount | `""`
`serviceAccount.annotations` | annotations for the ServiceAccount | `{}`

<hr>
</details>

### `extraManifests`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`extraManifests` | a list of extra Kubernetes manifests that will be deployed alongside the chart | `[]`

<hr>
</details>

### `pgbouncer.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`pgbouncer.enabled` | if the pgbouncer Deployment is created | `true`
`pgbouncer.image.*` | configs for the pgbouncer container image | `<see values.yaml>`
`pgbouncer.resources` | resource requests/limits for the pgbouncer Pods | `{}`
`pgbouncer.nodeSelector` | the nodeSelector configs for the pgbouncer Pods | `{}`
`pgbouncer.affinity` | the affinity configs for the pgbouncer Pods | `{}`
`pgbouncer.tolerations` | the toleration configs for the pgbouncer Pods | `[]`
`pgbouncer.securityContext` | the security context for the pgbouncer Pods | `{}`
`pgbouncer.labels` | labels for the pgbouncer Deployment | `{}`
`pgbouncer.podLabels` | Pod labels for the pgbouncer Deployment | `{}`
`pgbouncer.annotations` | annotations for the pgbouncer Deployment | `{}`
`pgbouncer.podAnnotations` | Pod annotations for the pgbouncer Deployment | `{}`
`pgbouncer.safeToEvict` | if we add the annotation: "cluster-autoscaler.kubernetes.io/safe-to-evict" = "true" | `true`
`pgbouncer.podDisruptionBudget.*` | configs for the PodDisruptionBudget of the pgbouncer | `<see values.yaml>`
`pgbouncer.livenessProbe.*` | configs for the pgbouncer Pods' liveness probe | `<see values.yaml>`
`pgbouncer.startupProbe.*` | configs for the pgbouncer Pods' startup probe | `<see values.yaml>`
`pgbouncer.terminationGracePeriodSeconds` | the maximum number of seconds to wait for queries upon pod termination, before force killing | `120`
`pgbouncer.authType` | sets pgbouncer config: `auth_type` | `md5`
`pgbouncer.maxClientConnections` | sets pgbouncer config: `max_client_conn` | `1000`
`pgbouncer.poolSize` | sets pgbouncer config: `default_pool_size` | `20`
`pgbouncer.logDisconnections` | sets pgbouncer config: `log_disconnections` | `0`
`pgbouncer.logConnections` | sets pgbouncer config: `log_connections` | `0`
`pgbouncer.clientSSL.*` | ssl configs for: clients -> pgbouncer | `<see values.yaml>`
`pgbouncer.serverSSL.*` | ssl configs for: pgbouncer -> postgres | `<see values.yaml>`

<hr>
</details>

### `postgresql.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`postgresql.enabled` | if the `stable/postgresql` chart is used | `true`
`postgresql.postgresqlDatabase` | the postgres database to use | `airflow`
`postgresql.postgresqlUsername` | the postgres user to create | `postgres`
`postgresql.postgresqlPassword` | the postgres user's password | `airflow`
`postgresql.existingSecret` | the name of a pre-created secret containing the postgres password | `""`
`postgresql.existingSecretKey` | the key within `postgresql.passwordSecret` containing the password string | `postgresql-password`
`postgresql.persistence.*` | configs for the PVC of postgresql | `<see values.yaml>`
`postgresql.master.*` | configs for the postgres StatefulSet | `<see values.yaml>`

<hr>
</details>

### `externalDatabase.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`externalDatabase.type` | the type of external database | `postgres`
`externalDatabase.host` | the host of the external database | `localhost`
`externalDatabase.port` | the port of the external database | `5432`
`externalDatabase.database` | the database/scheme to use within the the external database | `airflow`
`externalDatabase.user` | the username for the external database | `airflow`
`externalDatabase.userSecret` | the name of a pre-created secret containing the external database user | `""`
`externalDatabase.userSecretKey` | the key within `externalDatabase.userSecret` containing the user string | `postgresql-user`
`externalDatabase.password` | the password for the external database | `""`
`externalDatabase.passwordSecret` | the name of a pre-created secret containing the external database password | `""`
`externalDatabase.passwordSecretKey` | the key within `externalDatabase.passwordSecret` containing the password string | `postgresql-password`
`externalDatabase.properties` | extra connection-string properties for the external database | `""`

<hr>
</details>

### `redis.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`redis.enabled` | if the `stable/redis` chart is used | `true`
`redis.password` | the redis password | `airflow`
`redis.existingSecret` | the name of a pre-created secret containing the redis password | `""`
`redis.existingSecretPasswordKey` | the key within `redis.existingSecret` containing the password string | `redis-password`
`redis.cluster.*` | configs for redis cluster mode | `<see values.yaml>`
`redis.master.*` | configs for the redis master StatefulSet | `<see values.yaml>`
`redis.slave.*` | configs for the redis slave StatefulSet | `<see values.yaml>`

<hr>
</details>

### `externalRedis.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`externalRedis.host` | the host of the external redis | `localhost`
`externalRedis.port` | the port of the external redis | `6379`
`externalRedis.databaseNumber` | the database number to use within the external redis | `1`
`externalRedis.password` | the password for the external redis | `""`
`externalRedis.passwordSecret` | the name of a pre-created secret containing the external redis password | `""`
`externalRedis.passwordSecretKey` | the key within `externalRedis.passwordSecret` containing the password string | `redis-password`
`externalDatabase.properties` | extra connection-string properties for the external redis | `""` 

<hr>
</details>

### `serviceMonitor.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`serviceMonitor.enabled` | if ServiceMonitor resources should be deployed | `false`
`serviceMonitor.selector` | labels for ServiceMonitor, so that Prometheus can select it | `{ prometheus: "kube-prometheus" }`
`serviceMonitor.path` | the ServiceMonitor web endpoint path | `/admin/metrics`
`serviceMonitor.interval` | the ServiceMonitor web endpoint path | `30s`

<hr>
</details>

### `prometheusRule.*`
<details>
<summary>Expand</summary>
<hr>

Parameter | Description | Default
--- | --- | ---
`prometheusRule.enabled` | if the PrometheusRule resources should be deployed | `false`
`prometheusRule.additionalLabels` | labels for PrometheusRule, so that Prometheus can select it | `{}`
`prometheusRule.groups` | alerting rules for Prometheus | `[]`

<hr>
</details>
