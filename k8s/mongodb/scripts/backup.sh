#!/bin/bash


function usage {
usage="
\n
Usage: $(basename $0) [OPTIONS]\n
\n
Parameters:\n
-n              namespace\n
-c              mongodb container name\n
-p              pod name\n
-a              mongodb backupname\n
-h              usage help\n
\n
example:\n
./backup.sh -n mongodb-sc -c htestmongo -p htestmongo-0 -a backup-test
\n
"
echo -e $usage
}

if [[ $# -lt 8 ]]; then
    usage
    exit 1
fi
 
while getopts ":n:c:p:a:h" opt; do
  case $opt in
    a)
      backupFileName=$OPTARG
      ;;
    n)
        namespace=$OPTARG
      ;;
    c)
        container=$OPTARG
      ;;
    p)
        pod=$OPTARG
      ;;    
    :)
      usage
      exit 1
      ;;
    h)
      usage
      exit 1
      ;;
    *)
        echo "Bad parameter"
        usage
        exit 1
        ;;
  esac
done


kubectl -n ${namespace} exec  ${pod} --container ${container} -- /bin/bash -c "mongodump -o /${backupFileName}"
kubectl -n ${namespace} exec  ${pod} --container ${container} -- /bin/bash -c "tar -czf ${backupFileName}.tgz /${backupFileName}"
echo "Downloading backup file into local machine."
kubectl cp ${namespace}/${pod}:/${backupFileName}.tgz -c ${container} ./${backupFileName}.tgz
if [[ $? -ne 0 ]]; then
  echo "An error occurred while downloading the backup file. Aborting the execution of the backup script."
  exit 1
fi
echo "Removing backup file ${backupFileName} on the container."
kubectl exec -n ${namespace} ${pod} -c ${container} -- rm -rf $backupFileName $backupFileName*
if [[ $? -ne 0 ]]; then
  echo "An error occurred while removing the backup file on the container: ${container}"
  exit 1
fi
