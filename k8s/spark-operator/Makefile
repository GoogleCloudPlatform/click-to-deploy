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
  "serviceAccount": "$(NAME)-sa" \
}
TESTER_IMAGE ?= $(REGISTRY)/spark-operator/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/spark-operator/deployer \
            .build/spark-operator/spark-operator \
            .build/spark-operator/tester


.build/spark-operator: | .build
	mkdir -p "$@"


.build/spark-operator/deployer: schema.yaml \
                                deployer/* \
                                manifest/* \
                                .build/marketplace/deployer/envsubst \
                                .build/var/APP_DEPLOYER_IMAGE \
                                .build/var/REGISTRY \
                                .build/var/TAG \
                                | .build/spark-operator
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/spark-operator" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/spark-operator/tester: apptest/**/*
	$(call print_target, $@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


.build/spark-operator/spark-operator: .build/var/REGISTRY \
                                      .build/var/TAG \
                                      | .build/spark-operator
	$(call print_target, $@)
	docker pull gcr.io/spark-operator/spark-operator:v2.3.0-v1alpha1-latest
	docker tag gcr.io/spark-operator/spark-operator:v2.3.0-v1alpha1-latest "$(REGISTRY)/spark-operator:$(TAG)"
	docker push "$(REGISTRY)/spark-operator:$(TAG)"
	@touch "$@"


# TODO(huyhg): Remove once tools can provision it.
.PHONY: app/serviceaccount
app/serviceaccount:
	kubectl create serviceaccount "$(NAME)-sa"
	kubectl create clusterrolebinding "$(NAMESPACE)-$(NAME)-sa-rb" --clusterrole=cluster-admin --serviceaccount="$(NAMESPACE):$(NAME)-sa"
