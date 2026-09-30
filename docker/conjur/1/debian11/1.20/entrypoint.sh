#!/bin/bash -l

if [[ "$@" =~ "conjurctl server" ]] && [[ -z ${CONJUR_DATA_KEY} ]]; then
  export CONJUR_DATA_KEY=$(openssl rand -base64 32)
  echo "export CONJUR_DATA_KEY=\"$CONJUR_DATA_KEY\"" >> /etc/bash.bashrc
fi

exec "$@"
