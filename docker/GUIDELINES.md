## Docker Container Guidelines

### Versions

#### Directory path

For most cases `dir` should be `<major>/debian<version>/<major>.<minor>`.

Also other formats are acceptable, such as `<major>/php7/debian9/apache`.

```yaml {.good .no-copy highlight="content:3/debian9/3.4"}
versions:

  - dir: '3/debian9/3.4'
    repo: 'zookeeper3'
```

```yaml {.bad .no-copy highlight="content:3/3.4"}
versions:

  - dir: '3/3.4'
    repo: 'zookeeper3'
```

#### Repository name

A repository name should be `<container-name><major>`.

```yaml {.good .no-copy highlight="content:zookeeper3"}
versions:

  - dir: '3/debian9/3.4'
    repo: 'zookeeper3'
```

```yaml {.bad .no-copy highlight="content:zookeeper"}
versions:

  - dir: '3/debian9/3.4'
    repo: 'zookeeper'
```

#### Tags

Add tags in the following formats:

*   `<major>.<minor>.<build>`
*   `<major>.<minor>`
*   `<major>`

All the above tags must to have `-debian9` suffix or other representative
version.

A `latest` tag should point to the latest version of the repository defined in
`repo` field.

```yaml {.good .no-copy}
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

```yaml {.bad .no-copy}
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

<p class="bad">

```docker {.bad .no-copy}
FROM {{ .From }}

{{- $haproxy := index .Packages "haproxy" -}}

ENV HAPROXY_VERSION {{ $haproxy.Version }}
ENV C2D_RELEASE {{ $haproxy.Version }}
```
</p>


```docker {.good .no-copy}
{{- $haproxy := index .Packages "haproxy" -}}

FROM {{ .From }}

ENV HAPROXY_VERSION {{ $haproxy.Version }}
ENV C2D_RELEASE {{ $haproxy.Version }}
```

#### Spaces or tabs

Be consistent and use spaces or tabs, don't mix them.

It is always preferred to use spaces, however if the upstream code use already
tabs, you can follow it.

#### Best practise

Bring coffee and read
[Best practices for writing Dockerfiles](https://docs.docker.com/develop/develop-images/dockerfile_best-practices/).

<img src="css.svg" width="1" height="1">
