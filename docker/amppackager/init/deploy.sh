#!/bin/sh
# This shell script is used by the docker init container used in the
# click-to-deploy deployer for AMP Packager.

export GENFILES_DIR="$1"
export AMP_PACKAGER_NUM_REPLICAS=$2
export AMP_PACKAGER_DOMAIN=$3
export AMP_PACKAGER_COUNTRY="$4"
export AMP_PACKAGER_STATE="$5"
export AMP_PACKAGER_LOCALITY="$6"
export AMP_PACKAGER_ORGANIZATION="$7"
export AMP_PACKAGER_CERT_FILENAME="$8"
export AMP_PACKAGER_CSR_FILENAME="$9"
export AMP_PACKAGER_PRIV_KEY_FILENAME=${10}
export ACME_EMAIL_ADDRESS=${11}
export ACME_DIRECTORY_URL=${12}

echo "Env variables:"
printenv
echo "End Env variables:"

if [ ! -d "$GENFILES_DIR" ]; then
  echo "Creating generated/ directory"
  mkdir -p $GENFILES_DIR
fi

# All user/project specific information will be setup in ./setup.sh.
# source $CURRENT_DIR/setup.sh

# Note that PRIVATE KEY, SAN Config and CSR are optional steps. If you have
# these files generated already, you can copy them into this directory, using
# the naming convention you specifed in setup.sh.
# IMPORTANT: the private key, SAN, CSR and the certificate all go together,
# you cannot mix and match a new private key with an existing certificate and
# so on.

# *** PRIVATE KEY
# Generate prime256v1 ecdsa private key. If you already have a key,
# copy it to amppkg.privkey.
if [ -f "$GENFILES_DIR/$AMP_PACKAGER_PRIV_KEY_FILENAME" ]; then
  echo "$GENFILES_DIR/$AMP_PACKAGER_PRIV_KEY_FILENAME exists. Skipping generation."
else
  echo "Generating key ..."
  openssl ecparam -out "$GENFILES_DIR/$AMP_PACKAGER_PRIV_KEY_FILENAME" -name prime256v1 -genkey
fi

# *** SAN Config
# Generate the SAN file needed for CSR generation with the project specific values.
# See: https://ethitter.com/2016/05/generating-a-csr-with-san-at-the-command-line/
if [ -f "$GENFILES_DIR/san.cnf" ]; then
  echo "$GENFILES_DIR/san.cnf exists. Skipping generation."
else
  echo "Generating SAN file ..."
  cat san_template.cnf \
    | sed 's/$(AMP_PACKAGER_COUNTRY)/'"$AMP_PACKAGER_COUNTRY"'/g' \
    | sed 's/$(AMP_PACKAGER_STATE)/'"$AMP_PACKAGER_STATE"'/g' \
    | sed 's/$(AMP_PACKAGER_LOCALITY)/'"$AMP_PACKAGER_LOCALITY"'/g' \
    | sed 's/$(AMP_PACKAGER_ORGANIZATION)/'"$AMP_PACKAGER_ORGANIZATION"'/g' \
    | sed 's/$(AMP_PACKAGER_DOMAIN)/'"$AMP_PACKAGER_DOMAIN"'/g' \
    > $GENFILES_DIR/san.cnf
fi

# *** CSR
# Create a certificate signing request for the private key using the SAN config
# generated above. Copy the CSR to a safe place. If you already have a CSR,
# copy into amppkg.csr (or whatever you named it in setup.sh).
# To print 'openssl req -text -noout -verify -in amppkg.csr'
if [ -f "$GENFILES_DIR/$AMP_PACKAGER_CSR_FILENAME" ]; then
  echo "$GENFILES_DIR/$AMP_PACKAGER_CSR_FILENAME exists. Skipping generation."
else
  echo "Generating CSR ..."
  openssl req -new -sha256 -key "$GENFILES_DIR/$AMP_PACKAGER_PRIV_KEY_FILENAME" \
    -subj "/C=$AMP_PACKAGER_COUNTRY/ST=$AMP_PACKAGER_STATE/O=$AMP_PACKAGER_ORGANIZATION/CN=$AMP_PACKAGER_DOMAIN" \
    -nodes -out "$GENFILES_DIR/$AMP_PACKAGER_CSR_FILENAME" -outform pem -config $GENFILES_DIR/san.cnf
fi

# Generate the TOML files with the project specific values.
if [ -f "$GENFILES_DIR/amppkg_consumer.toml" ]; then
  echo "$GENFILES_DIR/amppkg_consumer.toml exists. Skipping generation."
else
  echo "Generating TOML files ..."
  cat amppkg_consumer_template.toml \
    | sed 's/$(AMP_PACKAGER_CERT_FILENAME)/'"$AMP_PACKAGER_CERT_FILENAME"'/g' \
    | sed 's/$(AMP_PACKAGER_CSR_FILENAME)/'"$AMP_PACKAGER_CSR_FILENAME"'/g' \
    | sed 's/$(AMP_PACKAGER_PRIV_KEY_FILENAME)/'"$AMP_PACKAGER_PRIV_KEY_FILENAME"'/g' \
    | sed 's/$(AMP_PACKAGER_DOMAIN)/'"$AMP_PACKAGER_DOMAIN"'/g' \
    > $GENFILES_DIR/amppkg_consumer.toml
fi

if [ -f "$GENFILES_DIR/amppkg_renewer.toml" ]; then
  echo "$GENFILES_DIR/amppkg_renewer.toml exists. Skipping generation."
else
  cat amppkg_renewer_template.toml \
    | sed 's/$(AMP_PACKAGER_CERT_FILENAME)/'"$AMP_PACKAGER_CERT_FILENAME"'/g' \
    | sed 's/$(AMP_PACKAGER_CSR_FILENAME)/'"$AMP_PACKAGER_CSR_FILENAME"'/g' \
    | sed 's/$(AMP_PACKAGER_PRIV_KEY_FILENAME)/'"$AMP_PACKAGER_PRIV_KEY_FILENAME"'/g' \
    | sed 's/$(AMP_PACKAGER_DOMAIN)/'"$AMP_PACKAGER_DOMAIN"'/g' \
    | sed 's/$(ACME_EMAIL_ADDRESS)/'"$ACME_EMAIL_ADDRESS"'/g' \
    | sed 's,$(ACME_DIRECTORY_URL),'"$ACME_DIRECTORY_URL"',g' \
    > $GENFILES_DIR/amppkg_renewer.toml
fi

# This assumes current working directory is amppackager/docker/gcloud
# default is the default namespace for the gcloud project
echo "Copying files to NFS mount ..."

mkdir -p $1/www

