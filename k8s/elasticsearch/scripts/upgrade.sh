#!/bin/bash

# Check for required environment variables
for var in NAME NAMESPACE IMAGE_ELASTICSEARCH ELASTIC_URL; do
  # add validation
  if ! [[ -v "${var}" ]]; then
    echo "\$${var} variable is unset - EXIT"
    exit 1
  fi
done


function wait_for_green_elastic_cluster() {
  local -r health_url="$ELASTIC_URL/_cluster/health?format=yaml"
  local -r status_health_url="${health_url}&filter_path=status"

  # Wait for status 'green'
  until curl -s -m 5 "${status_health_url}" | grep green; do
    echo "Waiting for green status in cluster..."
    sleep 3
  done

  echo "Cluster status: green"
}


function set_shard_allocation() {
  local -r value="$1"

  curl -s -X PUT "${ELASTIC_URL}/_cluster/settings" \
    -H 'Content-Type: application/json' \
    -d "{ \
         \"persistent\": { \
           \"cluster.routing.allocation.enable\": ${value} \
         } \
       }" > /dev/null

  echo "Shard allocation in cluster set to ${value}."
}


function perform_synced_flush() {
  curl -s -X POST "${ELASTIC_URL}/_flush/synced" > /dev/null
  echo "Synced flush operation triggered."
}


function wait_for_nodes_in_cluster() {
  local -r expected_nodes="$1"
  local nodes_in_cluster=$(curl -s -m 2 -X GET "${ELASTIC_URL}/_cat/nodes" | wc -l)
  while [[ "${nodes_in_cluster}" != ${expected_nodes} ]]; do
    sleep 2
    nodes_in_cluster=$(curl -s -m 5 -X GET "${ELASTIC_URL}/_cat/nodes" | wc -l)
    echo "Nodes in cluster: $nodes_in_cluster..."
  done
  echo "Reached the expected number of nodes in cluster: $expected_nodes."
}


function patch_image_definition() {
  # TODO: 
  kubectl patch sts ${NAME}-elasticsearch \
    --namespace $NAMESPACE \
    --type='json' \
    --patch="[{ \
        \"op\": \"replace\", \
        \"path\": \"/spec/template/spec/containers/0/image\", \
        \"value\": \"${IMAGE_ELASTICSEARCH}\" \
      }]"
  echo "StatefulSet image for Elasticsearch set to: ${IMAGE_ELASTICSEARCH}."
}


function get_number_of_replicas_in_sts() {
  kubectl get sts $NAME-elasticsearch \
    --namespace $NAMESPACE \
    -o jsonpath='{.spec.replicas}'
}


function delete_pod() {
  local -r pod_name="$1"
  kubectl delete pod ${pod_name} \
    --namespace $NAMESPACE
}


function main() {
  # TODO: connect to the cluster first - check if it is green

  local -r replicas=$(get_number_of_replicas_in_sts)
  local node=$(( replicas - 1 ))

  patch_image_definition # TODO: extract it to be done manually

  while (( node  >= 0 )); do
    set_shard_allocation \"none\" # Disable shard allocation
    sleep 3 # TODO: check the docs to eliminate the sleep

    perform_synced_flush # Perform a synced flush
    sleep $(( 2 * replicas )) # TODO: revisit sync documentation - is it async or not?

    delete_pod ${NAME}-elasticsearch-${node}
    sleep 2 # TODO: check the old pod UID, delete it, wait in a loop for the new pod - same name, different UID

    echo "Wait for node $node to join the cluster"
    wait_for_nodes_in_cluster $replicas

    set_shard_allocation null # Enable shard allocation
    wait_for_green_elastic_cluster # Wait for green status in cluster
    (( node-- ))
  done
}

main
