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
./restore.sh -n mongodb-sc -c htestmongo -p htestmongo-0 -a harnasDB-backup2.tgz
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
      echo "backupFileName: $backupFileName"
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
restoreName=$(echo $backupFileName | cut -d '.' -f1)
kubectl cp ./$backupFileName $namespace/$pod:/$backupFileName -c $container
kubectl -n $namespace exec  $pod --container $container -- /bin/bash -c "tar -xf $backupFileName"
kubectl -n $namespace exec  $pod --container $container -- /bin/bash -c "mongorestore /$restoreName/"
if [[ $? -ne 0 ]]; then
  echo "Error, the backup will not be restored on the container: ${container}"
  exit 1
fi
