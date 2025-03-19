jenkins-docker
============

Dockerfile source for Jenkins [docker](https://docker.io) image.

# Upstream
This source repo was originally copied from:
https://github.com/jenkinsci/docker

# Disclaimer
This is not an official Google product.

# <a name="about"></a>About

This image contains an installation of Jenkins 2.x.

For more information, visit the
[Marketplace page for Jenkins](https://console.cloud.google.com/marketplace/product/google/jenkins2).

Pull command (first install [gcloud](https://cloud.google.com/sdk/downloads)):

```shell
gcloud docker -- pull marketplace.gcr.io/google/jenkins2
```

The Dockerfile for this image can be found [here](https://github.com/GoogleCloudPlatform/jenkins-docker/tree/master/2).

# <a name="table-of-contents"></a>Table of Contents
* [Using Kubernetes](#using-kubernetes)
  * [Running Jenkins server](#running-jenkins-server-kubernetes)
    * [Starting a Jenkins instance](#starting-a-jenkins-instance-kubernetes)
  * [Configurations](#configurations-kubernetes)
    * [First log in](#first-log-in-kubernetes)
    * [Passing JVM arguments](#passing-jvm-arguments-kubernetes)
  * [Maintenance](#maintenance-kubernetes)
    * [Creating a Jenkins backup](#creating-a-jenkins-backup-kubernetes)
* [Using Docker](#using-docker)
  * [Running Jenkins server](#running-jenkins-server-docker)
    * [Starting a Jenkins instance](#starting-a-jenkins-instance-docker)
    * [Adding persistence](#adding-persistence-docker)
  * [Configurations](#configurations-docker)
    * [First log in](#first-log-in-docker)
    * [Passing JVM arguments](#passing-jvm-arguments-docker)
  * [Maintenance](#maintenance-docker)
    * [Creating a Jenkins backup](#creating-a-jenkins-backup-docker)
* [References](#references)
  * [Ports](#references-ports)
  * [Volumes](#references-volumes)

# <a name="using-kubernetes"></a>Using Kubernetes

For additional information about setting up your Kubernetes environment,
consult the
[official Google Cloud Marketplace documentation](https://cloud.google.com/marketplace/docs/container-images).

## <a name="running-jenkins-server-kubernetes"></a>Running your Jenkins server

This section describes how to spin up a Jenkins service using this image.

### <a name="starting-a-jenkins-instance-kubernetes"></a>Starting a Jenkins instance

Copy the following content to the file `pod.yaml`, and run `kubectl create -f pod.yaml`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-jenkins
  labels:
    name: some-jenkins
spec:
  containers:
    - image: marketplace.gcr.io/google/jenkins2
      name: jenkins
```

To expose the ports, run the following commands.

Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult the
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-jenkins --name some-jenkins-8080 \
  --type LoadBalancer --port 8080 --protocol TCP
kubectl expose pod some-jenkins --name some-jenkins-50000 \
  --type LoadBalancer --port 50000 --protocol TCP
```

To retain Jenkins data across container restarts, see [Adding persistence](#adding-persistence-kubernetes).

See [Configurations](#configurations-kubernetes) for how to customize your Jenkins service instance.

## <a name="configurations-kubernetes"></a>Configurations

### <a name="first-log-in-kubernetes"></a>Logging in for the first time

To log in for the first time, view the generated administrator password.

```shell
kubectl exec some-jenkins -- cat /var/jenkins_home/secrets/initialAdminPassword
```

### <a name="passing-jvm-arguments-kubernetes"></a>Passing JVM arguments

To pass JVM arguments, use the environment variable `JAVA_OPTS`. For example,
the following commands increase the size of the heap to 2G and the size of
PermGen to 128M:

Copy the following content to the `pod.yaml` file, and run
`kubectl create -f pod.yaml`:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: some-jenkins
  labels:
    name: some-jenkins
spec:
  containers:
    - image: marketplace.gcr.io/google/jenkins2
      name: jenkins
      env:
        - name: "JAVA_OPTS"
          value: "-Xmx2G -XX:MaxPermSize=128m"
```

To expose the ports, run the following commands:

Depending on your cluster setup, this might expose your service to the
Internet with an external IP address. For more information, consult the
[Kubernetes documentation](https://kubernetes.io/docs/concepts/services-networking/connect-applications-service/).

```shell
kubectl expose pod some-jenkins --name some-jenkins-8080 \
  --type LoadBalancer --port 8080 --protocol TCP
kubectl expose pod some-jenkins --name some-jenkins-50000 \
  --type LoadBalancer --port 50000 --protocol TCP
```

## <a name="maintenance-kubernetes"></a>Maintaining your deployment

### <a name="creating-a-jenkins-backup-kubernetes"></a>Creating a Jenkins backup

To back up your data, copy the directory `/var/jenkins_home` on the container
to the directory `/path/to/your/jenkins/home` on your host:

```shell
kubectl cp some-jenkins:/var/jenkins_home /path/to/your/jenkins/home
```

# <a name="using-docker"></a>Using Docker

For additional information about setting up your Docker environment,
visit the
[official Google Cloud Marketplace documentation](https://cloud.google.com/marketplace/docs/container-images).

## <a name="running-jenkins-server-docker"></a>Running your Jenkins server

This section describes how to use this image to spin up a Jenkins service.

### <a name="starting-a-jenkins-instance-docker"></a>Starting a Jenkins instance

Use the following content for your `docker-compose.yml` file, then run
`docker-compose up`:

```yaml
version: '2'
services:
  jenkins:
    container_name: some-jenkins
    image: marketplace.gcr.io/google/jenkins2
    ports:
      - '8080:8080'
      - '50000:50000'
```

You can also use `docker run` directly:

```shell
docker run \
  --name some-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -d \
  marketplace.gcr.io/google/jenkins2
```

Your Jenkins server is accessible on port 8080.

To retain Jenkins data across container restarts, refer to
[Adding persistence](#adding-persistence-docker).

For information about how to customize your Jenkins service instance,
refer to [Configurations](#configurations-docker).

### <a name="adding-persistence-docker"></a>Adding persistence

All Jenkins data is stored in `/var/jenkins_home`, including plugins and
configurations. To ensure that this data persists when the container
is restarted, this directory should be mounted on a persistent volume.

Assume that `/path/to/jenkins/home` is the persistent directory on your
host.

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  jenkins:
    container_name: some-jenkins
    image: marketplace.gcr.io/google/jenkins2
    ports:
      - '8080:8080'
      - '50000:50000'
    volumes:
      - /path/to/jenkins/home:/var/jenkins_home
```

You can also use `docker run`:

```shell
docker run \
  --name some-jenkins \
  -p 8080:8080 \
  -p 50000:50000 \
  -v /path/to/jenkins/home:/var/jenkins_home \
  -d \
  marketplace.gcr.io/google/jenkins2
```

## <a name="configurations-docker"></a>Configurations

### <a name="first-log-in-docker"></a>Logging in for the first time

To log in for the first time, view the generated administrator password:

```shell
docker exec some-jenkins cat /var/jenkins_home/secrets/initialAdminPassword
```

### <a name="passing-jvm-arguments-docker"></a>Passing JVM arguments

You can pass JVM arguments by using the environment variable `JAVA_OPTS`.
For example, the following commands increase the size of the heap to 2G and
the size of PermGen to 128M:

Use the following content for the `docker-compose.yml` file, then run `docker-compose up`.

```yaml
version: '2'
services:
  jenkins:
    container_name: some-jenkins
    image: marketplace.gcr.io/google/jenkins2
    environment:
      "JAVA_OPTS": "-Xmx2G -XX:MaxPermSize=128m"
    ports:
      - '8080:8080'
      - '50000:50000'
```

You can also use `docker run` directly:

```shell
docker run \
  --name some-jenkins \
  -e "JAVA_OPTS=-Xmx2G -XX:MaxPermSize=128m" \
  -p 8080:8080 \
  -p 50000:50000 \
  -d \
  marketplace.gcr.io/google/jenkins2
```

## <a name="maintenance-docker"></a>Maintaining your Jenkins deployment

### <a name="creating-a-jenkins-backup-docker"></a>Creating a Jenkins backup

To back up your data, copy the directory `/var/jenkins_home` on the container
to the directory `/path/to/your/jenkins/home` on your host:

```shell
docker cp some-jenkins:/var/jenkins_home /path/to/your/jenkins/home
```

# <a name="references"></a>References

## <a name="references-ports"></a>Ports

These are the ports exposed by the container image:

| **Port** | **Description** |
|:---------|:----------------|
| TCP 8080 | Jenkins console port. |
| TCP 50000 | Replica agent communication port. |

## <a name="references-volumes"></a>Volumes

These are the filesystem paths used by the container image:

| **Path** | **Description** |
|:---------|:----------------|
| /var/jenkins_home | Stores all of Jenkins plugins and configurations. |
