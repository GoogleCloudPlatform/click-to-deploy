#/bin/bash

docker run -e ZOO_4LW_COMMANDS_WHITELIST="*" \
    --name zk --restart always \
    -d gcr.io/ccm-ops-test-adhoc/zookeeper:3.6

docker run -d -p 8983:8983 -e \
    ZK_HOST=zk --link zk:zk \
    --name my_solr gcr.io/ccm-ops-test-adhoc/solr8 #\
    # solr-precreate gettingstarted

