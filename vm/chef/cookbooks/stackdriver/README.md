# Stackdriver Cookbook

WARNING: **DO NOT** include the `stackdriver` cookbook directly in other
cookbooks, but instead of that it should be included in a Packer template's
`run_list` attribute. To ensure that the Stackdriver agent is installed only in
the end solution.

Usage of Stackdriver [Logging](https://cloud.google.com/logging/) and
[Monitoring](https://cloud.google.com/monitoring/) is not free and we would like
to make sure that the agents are installed only in solutions that give end users
the ability to enable or disable the logging and monitoring in the UI.

## Logging

If the `google-logging-enable` metadata item is not present or is present with
value `"1"`, logging is enabled.

## Monitoring

If the `google-monitoring-enable` metadata item is not present or is present
with value `"1"`, monitoring is enabled.
