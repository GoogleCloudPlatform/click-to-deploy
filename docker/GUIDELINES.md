## Docker Container Guidelines

### Versions

#### Directory path

For most cases `dir` should be `<major>/debian<version>/<major>.<minor>`.

Also other formats are acceptable, such as `<major>/php8/debian11/apache`.

**Good**:
```yaml
versions:

  - dir: '3/debian9/3.4'
    repo: 'zookeeper3'
```

**Bad**:
```yaml
versions:

  - dir: '3/3.4'
    repo: 'zookeeper3'
```

#### Repository name

A repository name should be `<container-name><major>`.

**Good**:
```yaml
versions:

  - dir: '3/debian9/3.4'
    repo: 'zookeeper3'
```

**Bad**:
```yaml
versions:

  - dir: '3/debian9/3.4'
    repo: 'zookeeper'
```

#### Tags

Add tags in the following formats:

*   `<major>.<minor>.<build>`
*   `<major>.<minor>`
*   `<major>`

All the above tags must to have `-debian11` suffix or other representative
version.

A `latest` tag should point to the latest version of the repository defined in
`repo` field.

**Good**:
```yaml
versions:

  - tags:
      - '3.4.14-debian9'
      - '3.4.14'
      - '3.4-debian9'
      - '3.4'
      - '3-debian9'
      - '3'
      - 'latest'
```

**Bad**:
```yaml
versions:

  - tags:
      - '3.4'
      - '3'
```

### Dockerfiles

#### Template importings

All versions.yaml parameter importings should be located at the beginning of the
file. When you have a header in your file, add the importings after it.

If you have issues with extra-lines, check
[Go template documentation](https://golang.org/pkg/text/template/#hdr-Text_and_spaces).

**Good**:
```docker
FROM {{ .From }}

{{- $haproxy := index .Packages "haproxy" -}}

ENV HAPROXY_VERSION {{ $haproxy.Version }}
ENV C2D_RELEASE {{ $haproxy.Version }}
```
</p>


**Bad**:
```docker
{{- $haproxy := index .Packages "haproxy" -}}

FROM {{ .From }}

ENV HAPROXY_VERSION {{ $haproxy.Version }}
ENV C2D_RELEASE {{ $haproxy.Version }}
```

#### Spaces or tabs

Be consistent and use spaces or tabs, don't mix them.

It is always preferred to use spaces, however if the upstream code use already
tabs, you can follow it.

#### C2D Specifics

* Every container should be backed by Google Debian based images:
  * marketplace.gcr.io/google/debian11
* Containers should contain a `C2D_RELEASE` environment variable containing the main component version in the format `{major}.{minor}.{patch}`.

#### Best practice

Bring coffee and read
[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/).
