#!/bin/bash

prepare_gogs_config() {
    # create app.ini config
    mkdir -p /data/gogs/conf
    cat /app/gogs/app.ini.env | \
    envsubst > /data/gogs/conf/app.ini
}

create_volume_subfolder() {
    # only change ownership if needed, if using an nfs mount this could be expensive
    if [ "$USER:$USER" != "$(stat /data -c '%U:%G')" ]
    then
        # Modify the owner of /data dir, make $USER(git) user have permission to create sub-dir in /data.
        chown -R "$USER:$USER" /data
    fi
}

create_volume_subfolder
prepare_gogs_config

# Exec CMD or gogs by default if nothing present
if [ $# -gt 0 ];then
    exec "$@"
else
    exec /app/gogs/gogs web
fi
