#!/bin/bash -x

# Non-standard deployer entrypoint.
# This steps are needed to interfere with deployer - add new resource programatically
# before droping IAM permissions.

name="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"

namespace=$(cat /var/run/secrets/kubernetes.io/serviceaccount/namespace)
openssl req -x509 -nodes -days 365 -newkey rsa:2048 \
    -keyout /tmp/tls.key \
    -out /tmp/tls.crt \
    -subj "/CN=jenkins/O=jenkins"

kubectl --namespace ${namespace} create secret generic ${name}-tls \
	--from-file=/tmp/tls.crt --from-file=/tmp/tls.key

/bin/deploy-original.sh

application_uid=$(kubectl get applications/${name} --namespace=${namespace} --output=jsonpath='{.metadata.uid}')
kubectl patch secret ${name}-tls -p \
'
{
	"metadata": {
		"ownerReferences": [
			{
				"apiVersion":"app.k8s.io/v1beta1",
				"blockOwnerDeletion":true,
				"kind":"Application",
				"name":"'"${name}"'",
				"uid":"'"${application_uid}"'"
			}
		]
	}
}
'

NAME="$(/bin/print_config.py \
    --xtype NAME \
    --values_mode raw)"
NAMESPACE="$(/bin/print_config.py \
    --xtype NAMESPACE \
    --values_mode raw)"
export NAME
export NAMESPACE
/bin/clean_iam_resources-original.sh
