#!/bin/bash
~/bin/mpdev /scripts/verify \
 --deployer="gcr.io/amp-packager-market-public/amppackager/deployer:1.0" >& /tmp/amppackager-deployer.log &

