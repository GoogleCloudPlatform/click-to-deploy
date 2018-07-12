#!/bin/bash -x

/bin/expand_config.py
name="$(/bin/print_config.py --param '{"x-google-marketplace": {"type": "NAME"}}')"

namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /tmp/tls.key -out /tmp/tls.crt -subj "/CN=jenkins/O=jenkins"
kubectl --namespace $namespace create secret generic $name-tls \
	--from-file=/tmp/tls.crt --from-file=/tmp/tls.key \
	--dry-run -o yaml | kubectl apply -f -

/bin/deploy-org.sh

application_uid=$(kubectl get applications/$name --namespace=$namespace --output=jsonpath='{.metadata.uid}')
kubectl patch secret $name-tls -p "{\"metadata\":{\"ownerReferences\":[{\"apiVersion\":\"app.k8s.io/v1beta1\",\"blockOwnerDeletion\":true,\"kind\":\"Application\",\"name\":\"$name\",\"uid\":\"$application_uid\"}]}}"

NAME="$(/bin/print_config.py --param '{"x-google-marketplace": {"type": "NAME"}}')"
NAMESPACE="$(/bin/print_config.py --param '{"x-google-marketplace": {"type": "NAMESPACE"}}')"
export NAME
export NAMESPACE
/bin/clean_iam_resources-org.sh
