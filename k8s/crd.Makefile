ifndef __CRD_MAKEFILE__

__CRD_MAKEFILE__ := included


# Installs the application CRD on the cluster.
.PHONY: crd/install
crd/install:
	kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
	kubectl apply -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/kalm.yaml"


# Uninstalls the application CRD from the cluster.
.PHONY: crd/uninstall
crd/uninstall:
	kubectl delete -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/app-crd.yaml"
	kubectl delete -f "https://raw.githubusercontent.com/GoogleCloudPlatform/marketplace-k8s-app-tools/master/crd/kalm.yaml"


endif
