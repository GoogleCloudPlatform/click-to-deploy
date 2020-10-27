# AMP Packager

AMP Packager is a tool to [improve AMP URLs](https://blog.amp.dev/2018/11/13/developer-preview-of-better-amp-urls-in-google-search/)
by [serving AMP using Signed Exchanges](https://amp.dev/documentation/guides-and-tutorials/optimize-and-measure/signed-exchange/).
By running it in a proper configuration, web publishers enable origin URLs to
appear in AMP search results.

The AMP Packager works by creating [Signed HTTP
Exchanges (SXGs)](https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html)
containing AMP documents, signed with a certificate associated with the origin,
with a maximum lifetime of 7 days. The [Google AMP
Cache](https://amp.dev/documentation/guides-and-tutorials/learn/amp-caches-and-cors/how_amp_pages_are_cached/) will fetch,
cache, and serve them, similar to what it does for normal AMP HTML documents.
When a user loads such an SXG, Chrome validates the signature and then displays
the certificate's domain in the URL bar instead of `google.com`, and treats the
web page as though it were on that domain.

The packager is an HTTP server that sits behind a frontend server; it fetches
and signs AMP documents as requested by the AMP Cache.

As an alternative to running the packager, you can sign up for one of the SXG [service providers](https://github.com/ampproject/amppackager/wiki/Service-Providers).

## Packager/Signer

### How to use

In all the instructions below, replace `amppackageexample.com` with a domain you
own and can obtain certificates for.

#### Development server

##### Manual installation

  1. Install Go version 1.10 or higher. Optionally, set
     [$GOPATH](https://github.com/golang/go/wiki/GOPATH) to something (default
     is `~/go`) and/or add `$GOPATH/bin` to `$PATH`.
  1. Get amppackager.

     Check your Go version by running `go version`.
  
     For Go 1.14 and higher versions run:

       ```
       go get -u github.com/ampproject/amppackager/cmd/amppkg
       ```
     
     For Go 1.13 and earlier versions run:

       ```
       go get -u -mod=vendor github.com/ampproject/amppackager/cmd/amppkg
       ```

  1. Optionally, move the built `~/go/bin/amppkg` wherever you like.
  1. Prepare a temporary certificate and private key pair to use for signing the
     exchange when testing your config. Follow WICG
     [instructions](https://github.com/WICG/webpackage/tree/master/go/signedexchange#creating-our-first-signed-exchange)
     to ensure compliance with the [WICG certificate
     requirements](https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#cross-origin-cert-req).
  1. Create a file `amppkg.toml`. A minimal config looks like this:
     ```
     LocalOnly = true
     CertFile = 'path/to/fullchain.pem'
     KeyFile = 'path/to/privkey.pem'
     OCSPCache = '/tmp/amppkg-ocsp'

     [[URLSet]]
       [URLSet.Sign]
         Domain = "amppackageexample.com"
     ```
     More details can be found in [amppkg.example.toml](amppkg.example.toml).
  1. `amppkg -development`

     If `amppkg.toml` is not in the current working directory, pass
     `-config=/path/to/amppkg.toml`.

##### Docker

Follow the instructions [here](docker/README.md) on how to deploy a local Docker
container.

#### Test your config

  1. Run Chrome with the following command line flags:
     ```
     alias chrome = [FULL PATH TO CHROME BINARY]
     PATH_TO_FULLCHAIN_PEM = [FULL PATH TO fullchain.pem]
     chrome --user-data-dir=/tmp/udd\
         --ignore-certificate-errors-spki-list=$(\
            openssl x509 -pubkey -noout -in $PATH_TO_FULLCHAIN_PEM |\
            openssl pkey -pubin -outform der |\
            openssl dgst -sha256 -binary | base64)\
         --enable-features=SignedHTTPExchange\
            'data:text/html,<a href="https://localhost:8080/priv/doc/https://amppackageexample.com/">click me'
     ```
  2. Open DevTools. Check 'Preserve log'.
  3. Click the `click me` link.
  4. Watch the URL transmogrify! Verify it came from an SXG by switching
     DevTools to the Network tab and looking in the `Size` column for `(from
     signed-exchange)` and in the `Type` column for `signed-exchange`. Click on
     that row and then click on the Preview tab, to see if there are any errors.

#### Demonstrate privacy-preserving prefetch

This step is optional; just to show how [privacy-preserving
prefetch](https://wicg.github.io/webpackage/draft-yasskin-wpack-use-cases.html#private-prefetch)
works with SXGs.

  1. `go get -u github.com/ampproject/amppackager/cmd/amppkg_dl_sxg`.
  2. `amppkg_dl_sxg https://localhost:8080/priv/doc/https://amppackageexample.com/`
  3. Stop `amppkg` with Ctrl-C.
  4. `go get -u github.com/ampproject/amppackager/cmd/amppkg_test_cache`.
  5. `amppkg_test_cache`
  6. Open Chrome and DevTools, as above.
  7. Visit `https://localhost:8000/`. Observe the prefetch of `/test.sxg`.
  8. Click the link. Observe that the cached SXG is used.

#### Productionizing

For now, productionizing is a bit manual. The minimum steps are:

  1. Don't pass `-development` flag to `amppkg`. This causes it to serve HTTP
     rather than HTTPS, among other changes.
  2. Don't expose `amppkg` to the outside world; keep it on your internal
     network.
  3. Configure your TLS-serving frontend server to conditionally proxy to
     `amppkg`:
     1. If the URL starts with `/amppkg/`, forward the request unmodified.
     2. If the URL points to an AMP page and the `AMP-Cache-Transform` request
        header is present, rewrite the URL by prepending `/priv/doc` and forward
        the request.

        NOTE: If using nginx, prefer using `proxy_pass` with `$request_uri`,
        rather than using `rewrite`, as in [this PR](https://github.com/Warashi/try-amppackager/pull/3),
        to avoid percent-encoding issues.
     3. If at all possible, don't send URLs of non-AMP pages to `amppkg`; its
        [transforms](transformer/) may break non-AMP HTML.
     4. DO NOT forward `/priv/doc` requests; these URLs are meant to be
        generated by the frontend server only.
  4. For HTTP compliance, ensure the `Vary` header set to `AMP-Cache-Transform,
     Accept` for all URLs that point to an AMP page, irrespective of whether the
     response is HTML or SXG. (SXG responses that come from `amppkg` will have
     the appropriate `Vary` header set, so it may only be necessary to
     explicitly set the `Vary` header for HTML responses.)
  5. Get an SXG cert from your CA. It must use an EC key with the prime256v1
     algorithm, and it must have a [CanSignHttpExchanges
     extension](https://wicg.github.io/webpackage/draft-yasskin-httpbis-origin-signed-exchanges-impl.html#cross-origin-cert-req).
     One provider of SXG certs is [DigiCert](https://www.digicert.com/account/ietf/http-signed-exchange.php).
     You MUST use this in `amppkg.toml`, and MUST NOT use it in your frontend.
  6. Every 90 days or sooner, renew your SXG cert (per
     [WICG/webpackage#383](https://github.com/WICG/webpackage/pull/383)) and
     restart amppkg (per
     [#93](https://github.com/ampproject/amppackager/issues/93)).
  7. Keep amppkg updated from `releases` (the default branch, so `go get` works)
     about every ~2 months. The [wg-caching](https://github.com/ampproject/wg-caching)
     team will release a new version approximately this often. Soon after each
     release, Googlebot will increment the version it requests with
     `AMP-Cache-Transform`. Googlebot will only allow the latest 2-3 versions
     (details are still TBD), so an update is necessary but not immediately. If
     amppkg doesn't support the requested version range, it will fall back to
     serving unsigned AMP.

     To keep subscribed to releases, you can select "Releases only" from the
     "Watch" dropdown in GitHub, or use [various tools](https://stackoverflow.com/questions/9845655/how-do-i-get-notifications-for-commits-to-a-repository)
     to subscribe to the `releases` branch.

You may also want to:

  1. Launch `amppkg` as a restricted user.
  2. Save its stdout to a rotated log somewhere.
  3. Use the [provided tools](https://amp.dev/documentation/guides-and-tutorials/learn/validation-workflow/validate_amp/)
     to verify that your published AMP documents are valid, for instance just
     before publication, or with a regular audit of a sample of documents. The
     [transforms](transformer/) are designed to work on valid AMP pages, and
     may break invalid AMP in small ways.
  4. Setup
     [monitoring](#monitoring-amppackager-in-production-via-its-prometheus-endpoints)
     of `amppackager` and related requests to AMP document server.

Once you've done the above, you should be able to test by launching Chrome
without any command line flags. To test by visiting the packager URL directly,
first add a Chrome extension to send an `AMP-Cache-Transform: any` request
header. Otherwise, follow the above "Demonstrate privacy-preserving prefetch"
instructions.

##### Security Considerations

Signed exchanges come with some [security
considerations](https://wicg.github.io/webpackage/draft-yasskin-http-origin-signed-responses.html#security-considerations)
that publishers should consider. A starting list of recommendations based on
that:

 * Use different keys for the signed exchange cert and the TLS cert.
 * Only sign public content that's OK to be shared with crawlers.
 * Don't sign personalized content. (It's OK to sign content that includes
   static JS that adds personalization at runtime.)
 * Be careful when signing inline JS; if it includes a vulnerability, it may be
   possible for attackers to exploit it without intercepting the network path,
   for up to 7 days.

#### Testing productionization without a valid certificate

It is possible to test an otherwise fully production configuration without
obtaining a certificate with the `CanSignHttpExchanges` extension. `amppkg`
still needs to perform OCSP verification, so the Issuer CA must be valid (i.e.
no self-signed certificates). e.g. You can use a certificate from [Let's
Encrypt](https://letsencrypt.org/).

Running `amppkg` with the `-invalidcert` flag will skip the check for
`CanSignHttpExchanges`. This flag is not necessary when using the
`-development` flag.

Chrome can be configured to allow these invalid certificates with the
*Allow Signed HTTP Exchange certificates without extension* experiment:
chrome://flags/#allow-sxg-certs-without-extension

#### Redundancy

If you need to load balance across multiple instances of `amppkg`, you'll want
your `OCSPCache` to be backed by a shared storage device (e.g. NFS). It doesn't
need to be shared among all instances globally, but perhaps among all instances
per datacenter. The reason for this is to reduce the number of OCSP requests
`amppkg` needs to make, per [OCSP stapling
recommendations](https://gist.github.com/sleevi/5efe9ef98961ecfb4da8).

#### How will these web packages be discovered by Google?

Googlebot makes requests with an `AMP-Cache-Transform` header. Responses that
are [acceptable AMP SXGs](docs/cache_requirements.md) will be eligible for
display to SXG-supporting browsers, and the HTML payload will be extracted and
eligible for use in the AMP viewer in other browsers.

### Limitations

Currently, the packager will refuse to sign any AMP documents that hit the size
limit of 4MB. You can [monitor](monitoring.md#available-metrics) the size of
your documents that have been signed, to see how close you are to the limit.

The packager refuses to sign any URL that results in a redirect. This is by
design, as neither the original URL nor the final URL makes sense as the signed
URL.

To account for possible clock skew in user agents, the packager back-dates
packages by 24h, which means they effectively last only 6 days for most users.

This tool only packages AMP documents. To sign non-AMP documents, look at the
commandline tools on which this was based, at
https://github.com/WICG/webpackage/tree/master/go/signedexchange.

`<amp-install-serviceworker>` will fail inside of a signed exchange, due to a
[Chrome limitation](https://bugs.chromium.org/p/chromium/issues/detail?id=939237). The
recommendation is to ignore the console error, for now. This is because
amp-install-serviceworker will still succeed in the unsigned AMP viewer case,
and crawlers may reuse the contents of the signed exchange when displaying an
AMP viewer to browser versions that don't support SXG.

#### `<amp-script>`

If you have any inline `<amp-script>`s (those with a `script` attribute), then
the expiration of the SXG will be set based on the minimum `max-age` of those
`<amp-script>`s, minus one day (due to
[backdating](https://github.com/ampproject/amppackager/issues/397)). If
possible, prefer external `<amp-script>`s (those with a `src` attribute), which
do not have this limitation.

If inline is necessary, you will need to weigh the [security
risks](https://wicg.github.io/webpackage/draft-yasskin-http-origin-signed-responses.html#seccons-downgrades)
against the [AMP Cache requirement](docs/cache_requirements.md) for a minimum
`max-age` of `345600` (4 days). For SXGs shorter than that, the Google AMP Cache
will treat them as if unsigned (by showing an AMP Viewer).

#### How does `amppackager` process a document it cannot sign?

Packager will respond to every request with either a signed document, an
unsigned document, or an error.

It will sign every document it can. It may, however, decide not to,
for a number of reasons: the certificate may be invalid, the page may not be a
valid AMP page, the page may not be an AMP page at all, the page may be 4MB or
larger, etc. 

If packager cannot sign the document but can fetch it, it will proxy the
document unsigned.

If there was a problem with the gateway fetch request, or with the original
request, packager will respond with an HTTP error, and log the problem to
stdout.

You can monitor the packager's error rates, as well as the rates of signed
vs unsigned documents, via the tools discussed in the next section.

Specifically, you can monitor the requests that resulted in a signed or an
unsigned document via `documents_signed_vs_unsigned` metric, and the ones that
resulted in an error - via `total_requests_by_code_and_url` metric.

#### Monitoring `amppackager` in production via its Prometheus endpoints

Once you've run the `amppackager` server in production, you may want to
[monitor](monitoring.md) its health and performance. You may also monitor the
performance of the underlying requests to the AMP document server. You can
monitor both servers via the [Prometheus](https://prometheus.io/) endpoints
provided by `amppackager`. A few examples of questions you can answer:

*  Is `amppackager` up and running?
*  How many requests has it processed since it's been up?
*  What was the 0.9 percentile latency of handling those request?
*  How many of those requests have triggered a gateway request to the
   AMP document server? 
*  For those gateway requests, what was the 0.9 percentile latency of 
   the AMP document server?

You can perform one-off manual health inspections, visualize the real-time
stats, set up alerts, and more. To learn what are all the things you can
monitor, and how to do it, check the [monitoring manual](monitoring.md).

## Local Transformer

The local transformer is a library within the AMP Packager that transforms AMP
HTML for security and performance improvements. Ports of or alternatives to the
AMP Packager will need to include these transforms.

More info [here](transformer/README.md).
