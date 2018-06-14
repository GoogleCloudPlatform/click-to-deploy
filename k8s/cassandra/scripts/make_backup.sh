#!/bin/bash

set -eu

result=$(nodetool snapshot $1)

if [[ $? -ne 0 ]]; then
  echo "Error while making snapshot"
  exit 1
fi

timestamp=$(echo "$result" | awk '/Snapshot directory: / { print $3 }')

mkdir -p /tmp/backup

for i in $(find /var/lib/cassandra/data/$1 -name $timestamp); do
  table=$(echo "${i}" | awk -F "[/-]" '{print $7}')
  mkdir /tmp/backup/$table
  mv $i /tmp/backup/$table
done


tar -zcf /tmp/backup.tar.gz -C /tmp/backup .

nodetool clearsnapshot $1
