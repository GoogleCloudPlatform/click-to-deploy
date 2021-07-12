#!/bin/bash

function test_hc() {
  IMAGE="$1"
  UNIQUE="hazelcast"
  docker run --name some-$UNIQUE-id --net hazelcast -p 5701:5701 -e DEBUG_DOCKER_ENTRYPOINT='foo' -d "${IMAGE}"
  sleep 10s
  docker run --name some-$UNIQUE-id-1 --net hazelcast -p 5702:5701 -e DEBUG_DOCKER_ENTRYPOINT='foo' -d "${IMAGE}"
  sleep 10s
}

function test_mc() {
  IMAGE="$1"
  UNIQUE="hazelcast"
  docker run --name some-$UNIQUE-id-mc --net hazelcast -p 8080:8080 -e DEBUG_DOCKER_ENTRYPOINT='foo' -d "${IMAGE}"
}

function remove_all() {
  docker rm -f `docker ps -aq`
}

# tests for server
# curl -v -X POST -H 'Content-Type: text/plain' -d 'bar' http://some-hazelcast-id:5701/hazelcast/rest/maps/mapName/foo
# curl -X GET http://some-hazelcast-id:5701/hazelcast/rest/maps/mapName/foo

# tests for mancenter
# curl http://localhost:8080/hazelcast-mancenter/
# Hazelcast Management Center
