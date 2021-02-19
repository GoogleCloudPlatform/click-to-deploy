#!/bin/bash

source /opt/c2d/c2d-utils || exit 1

readonly mongodb_password="$(get_attribute_value "mongodb_admin_password")"

export MONGODB_USERNAME="admin"
export MONGODB_PASSWORD="${mongodb_password}"
export MONGODB_NAME="test"
