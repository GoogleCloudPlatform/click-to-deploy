#!/bin/sh

set -ae

# GC logging set to default value of path.logs
CRATE_GC_LOG_DIR="/data/log"
CRATE_HEAP_DUMP_PATH="/data/data"
# Make sure directories exist as they are not automatically created
# This needs to happen at runtime, as the directory could be mounted.
mkdir -pv $CRATE_GC_LOG_DIR $CRATE_HEAP_DUMP_PATH

# Special VM options for Java in Docker
CRATE_JAVA_OPTS="-Des.cgroups.hierarchy.override=/ $CRATE_JAVA_OPTS"

if [ "${1:0:1}" = '-' ]; then
    set -- crate "$@"
fi

if [ "$1" = 'crate' -a "$(id -u)" = '0' ]; then
    chown -R crate:crate /data
    exec chroot --userspec=1000 / "$@"
fi

exec "$@"
