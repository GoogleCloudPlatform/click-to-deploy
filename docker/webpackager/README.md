# Web Packager Server

Web Packager HTTP Server is an HTTP server built on top of Web Packager.
It functions like a reverse-proxy, fetching documents from a backend server,
then optimizing and signing them before returning them to requestors. This
is similar to [AMP Packager][], but Web Packager targets all HTML documents
except for AMP documents, whereas AMP Packager packages AMP documents. It aims
to meet the [requirements][] set by the Google SXG Cache.

Currently, if you need to package [AMP][] documents into a signed exchange,
it is recommended that you use [AMP Packager][] for that purpose and use
[Web Packager][] for everything else. This may change in the future where only
one packager does both jobs, but for now it means that you have to set up both
packagers if you need to process both AMP and non-AMP content.

For general information about Web Packager, see [README.md](../../README.md)
in the repository root.

[AMP]: https://amp.dev/
[AMP Packager]: https://github.com/ampproject/amppackager
[requirements]: https://github.com/google/webpackager/blob/master/docs/cache_requirements.md
[Web Packager]: https://github.com/google/webpackager

## Prerequisites

1.  Web Packager and its associated HTTP server is written in the Go language
    thus it requires a Go development environment to run. See [Getting Started
    on golang.org][golang] for how to install Go on your computer.

2.  You will also need a certificate and private key pair to use for signing the
    exchanges. The certificate must:

    *   use an ECDSA private key (e.g. prime256v1) generated using:

        ```bash
        $ openssl ecparam -out $PRIV_KEY_FILE -name prime256v1 -genkey
        ```

    *   have the [CanSignHttpExchanges][] extension.
    *   last no longer than 90 days.

    Currently only [DigiCert][] offers these types of certificates. Please
    follow the instructions on their page regarding what needs to be done to
    order your certificate.  In particular, take note of:

    *   [Set up your domain's CAA resource record][CAA]. If you use WHOIS
        verification, please remember to turn off the privacy settings for your
        WHOIS record.
    *   [Creating an ECC CSR (Certificate Signing Request)][CSR].

[golang]: https://golang.org/doc/install
[CanSignHttpExchanges]: https://wicg.github.io/webpackage/draft-yasskin-http-origin-signed-responses.html#cross-origin-cert-req
[DigiCert]: https://www.digicert.com/account/ietf/http-signed-exchange.php
[CAA]: https://docs.digicert.com/manage-certificates/certificate-profile-options/get-your-signed-http-exchange-certificate/#set-up-your-domains-caa-resource-record
[CSR]: https://docs.digicert.com/manage-certificates/certificate-profile-options/get-your-signed-http-exchange-certificate/#create-an-ecc-csr

## Testing with self-signed / invalid certificates

It is possible to test an otherwise fully production configuration without
obtaining a certificate with the `CanSignHttpExchanges` extension. If you set
`AllowTestCert` to true in the TOML config file (explained later),
`webpkgserver` accepts whichever certificate the user provides
(including self-signed certificate) and uses it as if it were a valid signed
exchange certificate. You can also use a certificate from [Let's Encrypt][] this
way.

[Let's Encrypt]: https://letsencrypt.org/

Chrome can be configured to allow these invalid certificates with the Allow
Signed HTTP Exchange certificates without extension experiment:
chrome://flags/#allow-sxg-certs-without-extension.

You can run Chrome with these command line flags to ignore certificate errors:

```bash
--user-data-dir=/tmp/udd
--ignore-certificate-errors-spki-list=$(openssl x509 -pubkey -noout -in path/to/YOUR_CERT_HERE.pem | openssl pkey -pubin -outform der | openssl dgst -sha256 -binary | base64)
--enable-features=SignedHTTPExchange
'data:text/html,<a href="https://localhost:8080/priv/doc/https://YOUR_TEST_URL_HERE/">click me</a>'
```

When you start Chrome with this flag, Chrome will show a butter bar that looks
like an error (which is actually a warning) that says something about
"unsupported command-line flag". **That is expected and is working as intended**.

## Configuration

To build the Web Packager Server assuming installed the source in `webpackager`
directory:

```bash
$ cd wpkserver/cmd/webpkgserver
$ go build .
```

To bring up your instance, create your own copy of the config file named
webpkgserver.toml in the current directory (the binary looks for the toml config
in the current directory) from webpkgserver.example.toml:

```bash
$ cp /path/to/webpkgserver.example.toml ./webpkgserver.toml
```

Below you'll find the contents of the `webpkgserver.example.toml` that contain
information needed for creating signed exchanges:

```
[Listen]
    # The port number to listen on. If it is unspecified, webpkgserver will use
    # an arbitrary port number.
    Port = 8080

[SXG.Cert]
    # The path to the PEM file containing the full certificate chain, ordered
    # from the leaf to the root.
    PEMFile = 'path/to/your.pem'

    # The path to the PEM file containing the private key that corresponds to
    # the leaf certificate in PEMFile.
    KeyFile = 'path/to/your.key

    # Use any certificate for signing exchanges. If this parameter is set true,
    # webpkgserver will not verify that the certificate meets the requirements
    # set by the Signed HTTP Exchanges specification, so you can use ordinary
    # TLS certificates or self-signed certificates. Note those certificates only
    # work for testing: the produced signed exchanges will be deemed invalid due
    # to the certificate.
    #
    # If the certificate is missing an OCSP URL, webpkgserver substitutes dummy
    # bytes for the OCSP response.
    AllowTestCert = true

[[Sign]]
    # The domain to limit signed URLs to, case-insensitive. The certificate is
    # supposed to cover this domain.
    Domain = 'example.com'
```

Then run:

```bash
$ webpkgserver
```

NOTE: If you created `webpkgserver.toml` elsewhere or with a different name, pass
the `--config` option to webpkgserver so that it can locate your config file.
For example:

```bash
$ webpkgserver --config /path/to/webpkgserver.toml
```

To quickly check your instance is running:

```bash
$ curl -o out.sxg http://localhost:8080/priv/doc/https://example.com/
```

Adjust `localhost:8080` and `https://example.com/` according to the settings in
the .toml file. Note that `/priv/doc` is a special prefix that webpkgserver uses
to process incoming signed exchange files. It is not a real directory that has
to exist on your local machine.

You can check if the signed exchange is valid by using [dump-signedexchange][]:

```bash
$ go get -u github.com/WICG/webpackage/go/signedexchange/cmd/dump-signedexchange
$ dump-signedexchange -i out.sxg -verify
```

Please check that the content-body is not empty when you are doing your tests.

[dump-signedexchange]: https://github.com/WICG/webpackage/tree/master/go/signedexchange#dump-a-signed-exchange-file

## Running behind Front-end Edge Server

The setup is similar to [AMP Packager][]:

*   If the URL starts with `/webpkg/`, forward the request unmodified. In NGINX
    the directive would look like:

    ```
    location /webpkg/ {
        proxy_pass http://127.0.0.1:8080;
    }
    ```

*   If the request is requesting for a signed exchange rewrite the URL by
    prepending `/priv/doc/` and forward the request. In NGINX the directive
    would look like:

    ```
    proxy_pass http://127.0.0.1:8080/priv/doc/https://example.com$request_uri;
    ```

    where `$request_uri` will be the path and not the full URL. For example,
    this would expand to something like:

    ```
    http://127.0.0.1:8080/priv/doc/https://example.com/foo.html
    ```

*   Do not forward any other requests without adding the `/priv/doc` prefix
    (in particular, external requestors should not be able to formulate custom
    `/priv/doc` requests).

*   Do not forward any requests that have user-personalized content in them.
    Consult the [spec][] about the dangers of indiscriminately signing content.
    If a publisher indiscriminately signs all responses as their origin, they
    can cause at least two kinds of problems described in the spec:
    [session fixation][] and [misleading content][].

[spec]: https://wicg.github.io/webpackage/draft-yasskin-http-origin-signed-responses.html#name-over-signing
[session fixation]: https://wicg.github.io/webpackage/draft-yasskin-http-origin-signed-responses.html#section-6.1.1
[misleading content]: https://wicg.github.io/webpackage/draft-yasskin-http-origin-signed-responses.html#section-6.1.2

*   Every 90 days or sooner, renew your SXG cert and restart webpkgserver.

*   Content negotiation setup should be based on the `Accept` header. See the
    section on Content Negotiation for further details.

## Content Negotiation

[Content negotiation][conneg] (conneg) setup should be based on the [Accept][]
header. Content negotiation is a mechanism defined in the HTTP specification
that makes it possible to serve different versions of a document (or more
generally, a resource representation) at the same URI, so that user agents can
specify which version fits their capabilities the best.

For a given URL, Googlebot will request `application/signed-exchange;v=b3`
with [q-value][] equal to that of text/html, while Chromium browsers will
request it with q-score less than text/html, and other browsers won't
specify it at all (but may include `*/*`). Publishers should only serve SXG
to crawlers, based on that accept header. Based on the team’s experience,
it is difficult to set up an edge server that accurately handles headers
with q-scores. We therefore recommend matching on an Accept directive with
the following regular expression:

    ```
    Accept: /(^|,)\s*application\/signed-exchange\s*;\s*v=b3\s*(,|$)/
    ```

The `(,|$)` in that regex is important, as it indicates lack of a q
parameter, which differentiates Googlebot from Chromium.

Here are details on how different web server setups handle accept headers:

*   Listed below is a sample `VirtualHost` configuration for Apache:

    ```
    <VirtualHost *:443>
    Protocols  http/1.1
    ServerName www.example.com
    ServerAdmin webmaster@localhost
    DocumentRoot /usr/local/apache2/htdocs/

    <Directory "/usr/local/apache2/htdocs/sxg_test/">
        RewriteEngine On
        RewriteCond %{HTTP:Accept} (^|,)\s*application/signed-exchange\s*;\s*v=b3\s*(,|$)
        RewriteRule .+ http://localhost:8080/priv/doc/https://www.example.com%{REQUEST_URI} [P]

        Header set X-Content-Type-Options: "nosniff"
    </Directory>

    ProxyRequests on
    ProxyPass /webpkg/ http://localhost:8080/webpkg/

    SSLCertificateFile /usr/local/apache2/conf/fullchain.pem
    SSLCertificateKeyFile /usr/local/apache2/conf/privkey.pem
    Include /usr/local/apache2/conf/options-ssl-apache.conf
    </VirtualHost>
    ```

*   NGINX doesn't support conneg natively. Supporting it makes use of
    regexes and scripts that parse `Accept` only approximately.

    ```
    if ($http_accept ~* "(^|,)\s*application/signed-exchange\s*;\s*v=b3\s*(,|$)") {
       /* do processing */
    }
    ```

*   IIS has a [CLR API][CLR] that supports q-values. We haven't
    researched how to configure that for a reverse proxy setup.

[conneg]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Content_negotiation
[Accept]: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Accept
[q-value]: https://developer.mozilla.org/en-US/docs/Glossary/Quality_values
[CLR]: https://docs.microsoft.com/en-us/aspnet/web-api/overview/formats-and-model-binding/content-negotiation

## Limitations

Web Packager is currently at the alpha phase: it is not fully tested yet and
must be used with caution in any production environment. Also we may make
backward-breaking changes at any time.

Web Packager does not handle [request matching][] correctly. It should not
matter unless your web server implements content negotiation using the
`Variants` and `Variant-Key` headers (*not* the `Vary` header). We plan to
support the request matching in future, but there is no ETA (estimated time of
availability) at this moment.

**Note:** The above limitation is not expected to be a big deal even if your
    server serves signed exchanges conditionally using content negotiation:
    if you already have signed exchanges, you should not need Web Packager.

[request matching]: https://wicg.github.io/webpackage/loading.html#request-matching
