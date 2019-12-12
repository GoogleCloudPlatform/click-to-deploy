# Dynamically set the protocol based on current request
function get_request_protocol() {
    if (array_key_exists("HTTP_X_FORWARDED_PROTO", $_SERVER)) {
        # GKE via Ingress
        return $_SERVER["HTTP_X_FORWARDED_PROTO"];
    } else {
        # No Ingress or docker run
        return stripos($_SERVER["SERVER_PROTOCOL"], "https") === 0 ? "https" : "http";
    }
}

## The URL base path to the directory containing the wiki;
## defaults for all runtime URL paths are based off of this.
## For more information on customizing the URLs
## (like /w/index.php/Page_title to /wiki/Page_title) please see:
## https://www.mediawiki.org/wiki/Manual:Short_URL
$wgScriptPath = "";

## The protocol and server name to use in fully-qualified URLs
$wgServer = sprintf("%s://%s", get_request_protocol(), $_SERVER["HTTP_HOST"]);

## The URL path to static resources (images, scripts, etc.)
$wgResourceBasePath = $wgScriptPath;

## The URL path to the logo. Make sure you change this from default,
## or else you'll overwrite your logo when you upgrade!
$wgLogo = "$wgResourceBasePath/resources/assets/wiki.png";

## Additional configuration can be found at:
## https://www.mediawiki.org/wiki/LocalSettings.php
