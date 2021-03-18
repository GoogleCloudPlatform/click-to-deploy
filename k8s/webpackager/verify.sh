#!/bin/bash
~/bin/mpdev /scripts/verify \
 --deployer="gcr.io/amp-packager-market-public/webpackager/deployer:1.0" >& /tmp/webpackager-deployer.log &

