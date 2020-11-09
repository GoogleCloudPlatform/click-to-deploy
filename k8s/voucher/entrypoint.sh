#!/bin/sh


while [ $# -gt 0 ]; do
  case "$1" in
    -project=*|--project=*)
      project="${1#*=}"
      ;;
    -auth=*|--auth=*)
      auth="${1#*=}"
      ;;
    -username=*|--username=*)
      username="${1#*=}"
      ;;
    -passhash=*|--passhash=*)
      passhash="${1#*=}"
      ;;
    -kms=*|--kms=*)
      kms="${1#*=}"
      ;;
    *)
      printf "***************************\n"
      printf "* Error: Invalid argument.*\n"
      printf "***************************\n"
      exit 1
  esac
  shift
done

if [ -z "$project" ] ; then echo "project is not set" && exit 1; fi
if [ -z "$auth" ] ; then echo "auth is not set" && exit 1; fi
if [ -z "$kms" ] ; then echo "kms is not set" && exit 1; fi

echo $project
echo $auth
echo $username
echo $passhash
echo $kms

cat /usr/local/config.toml.template \
| sed -e "s?<PROJECT_ID>?${project}?g" \
| sed -e "s?<KMS_KEY_NAME>?${kms}?g" \
| sed -e "s?<AUTH>?${auth}?g" \
| sed -e "s?<USERNAME>?${username}?g" \
| sed -e "s?<PASSHASH>?${passhash}?g" \
  > /usr/local/config.toml

cat /usr/local/config.toml

voucher_server -c /usr/local/config.toml
