include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= latest
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/spark-operator/deployer:$(TAG)
NAME ?= spark-operator-1
# TODO(huyhg): Remove serviceAccount from APP_PARAMETERS
# once tools can provision it.
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "serviceAccount": "spark-sa" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/spark-operator/deployer \
            .build/spark-operator/spark-operator


.build/spark-operator: | .build
	mkdir -p "$@"


.build/spark-operator/deployer: schema.yaml \
                                manifest/* \
                                .build/marketplace/deployer/envsubst \
                                .build/var/APP_DEPLOYER_IMAGE \
                                .build/var/REGISTRY \
                                .build/var/TAG \
                                | .build/spark-operator
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/spark-operator" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/spark-operator/spark-operator: .build/var/REGISTRY \
                                      .build/var/TAG \
                                      | .build/spark-operator
	docker pull gcr.io/spark-operator/spark-operator:v2.3.0-v1alpha1-latest
	docker tag gcr.io/spark-operator/spark-operator:v2.3.0-v1alpha1-latest "$(REGISTRY)/spark-operator:$(TAG)"
	docker push "$(REGISTRY)/spark-operator:$(TAG)"
	@touch "$@"


# TODO(huyhg): Remove once tools can provision it.
.PHONY: app/serviceaccount
app/serviceaccount:
	kubectl create serviceaccount spark-sa
	kubectl create clusterrolebinding test-cli-spark-sa-rb --clusterrole=cluster-admin --serviceaccount=$(NAMESPACE):spark-sa
