#!/bin/bash

set -eu

KEYSPACE=$1
SEEDS=$2

mkdir -p "/tmp/${KEYSPACE}"
mkdir -p /tmp/backup
tar -zxf /tmp/backup.tar.gz -C /tmp/backup

for table in $(ls /tmp/backup); do
  timestamp=$(ls "/tmp/backup/${table}")
  mkdir -p "/tmp/${KEYSPACE}/${table}"
  mv /tmp/backup/${table}/${timestamp}/* "/tmp/$KEYSPACE/$table/"
  sstableloader -d "${SEEDS}" "/tmp/${KEYSPACE}/${table}"
  rm -rf "/tmp/${KEYSPACE}/${table}"
done

rm -rf /tmp/backup
rm -rf "/tmp/${KEYSPACE}"
rm -rf /tmp/backup.tar.gz
