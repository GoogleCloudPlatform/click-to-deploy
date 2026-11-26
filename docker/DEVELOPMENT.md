# Developing a Container Solution

## Overview

Our containers are usually based on the original upstream source with some
adaptations depending on the solution drawn. Good practice is to implement any
custom configuration related to the Kubernetes App on the application side, and
keep containers generic. Though in some cases some customization might be
needed, eg:

*   Facilitate integration between dependencies
*   Embed custom features which the app provides, some examples:
    *   Expose relevant configuration parameters
    *   Enable or disable HTTPS based on a configuration

## Developing the Container

All new code written for the container which is not part of the upstream repo
should follow our [guidelines](GUIDELINES.md).

All C2D Containers should follow the same structure of other owned containers,
[check out the list](https://github.com/GoogleCloudPlatform/click-to-deploy/tree/master/docker).

Push the code to a feature branch with the pattern: `{user}-docker-{solution}`
(eg. `miani-docker-nodejs`).

### Directory structure

Our repositories may contain several versions of the same container, which are
generated from templates. Each item in repo is explained in more detail in next
steps.

Example directory structure:

```
click-to-deploy/docker/<container_name>
├── <major>
│   └── debian<version>
│       └── <major>.<minor>
│           ├── docker-entrypoint.sh
│           └── Dockerfile
├── exporter [OPTIONAL]
│   ├── docker-entrypoint.sh
│   └── Dockerfile
├── LICENSE
├── README.md
├── templates
│   └── <solution> # nested if other templates present
│       |          # otherwise might be directly within templates
│       ├── docker-entrypoint.sh
│       └── Dockerfile.template
│   └── exporter [OPTIONAL]
│       ├── docker-entrypoint.sh
│       └── Dockerfile.template
├── tests
│   └── functional_tests
│       └── <name>_test.yaml
└── versions.yaml
```

### Prepare main functionality

Create following files:

1.  `versions.yaml` - contains list of versions, which corresponds to the list
    of subdirectories

2.  `Dockerfile.template` template - target `Dockefiles` is generated based on
    it for each version in `versions.yaml`

3.  `docker-entrypoint.sh`, optional configuration files and scripts - copied as
    is to version subdirectories

4.  [Optional] Prometheus metrics exporter, possible two scenarios:

    *   Built in main container
    *   Additional container for metrics exporter. In this case `exporter`
        subdir should be created in `templates` folder

Generate dockerfiles for each version:

1.  Setup `dockerfiles` tool.

  ```shell
  curl -L -o dockerfiles https://github.com/GoogleCloudPlatform/click-to-deploy/releases/download/v1.0.2/dockerfiles
  chmod +x dockerfiles
  sudo mv dockerfiles /usr/local/bin/
  ```

2.  Generate files:

    ```shell
    dockerfiles -create_directories
    ```

3.  Check generated folders for versions specified. Each folder should contain
    `Dockerfile` generated from `Dockerfile.template`, `docker-entrypoint.sh`
    and any additional file present in `templates`

### Additional images

If your solution have additional images, eg. `exporter` you should publish it as
separate solution on GCP Marketplace:

eg. Postgresql container:

```yaml
versions:
- dir: 13/debian9/13.4
  repo: postgresql13
  ...
- dir: exporter
  repo: postgresql-exporter0
  ...
```

versions present in `versions.yaml` are published as separate solutions in
[marketplace.gcr.io/google/postgresql13](http://marketplace.gcr.io/google/postgresql13)
and
[marketplace.gcr.io/google/postgresql-exporter0](http://marketplace.gcr.io/google/postgresql-exporter0)
respectively.

### Functional tests

#### Adding functional tests

Container tests are based on
[functional_tests](https://github.com/GoogleCloudPlatform/runtimes-common/tree/master/functional_tests)
framework.

Yaml files containing tests should be placed in `tests/functional_tests`
directory.

`versions.yaml` supports `excludeTests` attribute to blacklist one or more tests
for specific versions.

<section class="zippy">

Example excludes

```yaml
- dir: 3/debian10/3.7
  excludeTests:    # exclude tests dedicated for exporter from main container
  - tests/functional_tests/exporter_test.yaml
  ...
- dir: exporter
  excludeTests:    # exclude tests dedicated for main container from exporter
  - tests/functional_tests/running_test.yaml
```

</section>

#### Debugging tests

If you need to run a test locally, navigate to the repository directory and
invoke the following command:

```shell
docker run --rm -it \
  -v $PWD/tests/functional_tests:/functional_tests:ro \
  -v /var/run/docker.sock:/var/run/docker.sock \
  gcr.io/cloud-marketplace-ops-test/functional_test \
    --verbose \
    --vars UNIQUE=$RANDOM \
    --vars IMAGE=marketplace.gcr.io/google/wordpress5-php7-apache:latest \
    --test_spec /functional_tests/apache_exporter_test.yaml
```

Where:

`--verbose` *(Optional)*: Verbose logging.

`--vars` *(Optional)*: Variable substitutions.

`--test_spec`: Path to a yaml or json file containing the test spec. In the
example above, `apache_exporter_test.yaml` test is executed.

### Prepare documentation

1.  Add `README.md` file

    <section class="zippy">
     README.md file example

    ```
     neo4j-docker
     ============

     <Product description>

     ## Upstream <!-- OPTIONAL -->

     This source repo was originally copied from: https://github.com/neo4j/docker-neo4j

     # Disclaimer

     This is not an official Google product.

     # About

     <More info on the container, instructions on how to run, references on variables, ports, volumes etc.>
    ```

    > **Note**: Upstream section is optional. Only add if container is based on
    > external repo. Skip if container is developed from scratch.

    </section>

1.  Add `LICENSE` file:

    *   If container is based on published upstream repository the license
        should be preserved. Eg.
        [wordpress-docker](https://github.com/GoogleCloudPlatform/wordpress-docker/blob/master/LICENSE)
        repo is using same licence as
        [upstream](https://github.com/docker-library/wordpress/blob/master/LICENSE)
        repo.
    *   The License should correspond to the code you are mirroring, not the
        package/software installed inside container. Eg. `neo4j` is under GPLv3
        [license](https://github.com/neo4j/neo4j/blob/4.3/LICENSE.txt) but
        `neo4j-docker` is under Apache 2
        [license](https://github.com/neo4j/docker-neo4j/blob/master/LICENSE). As
        our container is based on `neo4j-docker` code, it should use Apache2
        [license](https://github.com/GoogleCloudPlatform/click-to-deploy/blob/master/docker/neo4j/LICENSE).
    *   If the container is created from scratch, use default License for Click
        to Deploy project which is
        [Apache 2](https://github.com/GoogleCloudPlatform/click-to-deploy/blob/master/docker/activemq/LICENSE).

## OSPO

OSPO is a Google Program meant to validate whether a solution can be
open-sourced.

## Publish solution to Marketplace

1.  Raise a [GitHub Issue](https://github.com/GoogleCloudPlatform/click-to-deploy/issues) requesting the solution publishing. Please, specify:
    * Contact data (Email)
    * Github Pull Request
    * Logo URL (Minimum size: 512x512)
    * Solution:
      * Description (~300 chars)
      * Tagline (~100 chars)
      * End-user documentation links
      * License public URLs

2.  When the Issue is raised, some internal steps should be performed, as follows:

    * OSPO validation
    * CI configuration
    * Vulnerability Scanning
    * Solution metadata creation

3. Status reporting will be done via PR comments.

Thanks for your contribution!
