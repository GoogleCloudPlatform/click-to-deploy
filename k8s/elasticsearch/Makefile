APP_NAME = elasticsearch

tools_path = ../vendor/marketplace-tools

include $(tools_path)/gcloud.Makefile

include $(tools_path)/crd.Makefile
include $(tools_path)/app.Makefile
include $(tools_path)/ubbagent.Makefile

REGISTRY_FOR_DEPLOYER ?= $(APP_REGISTRY)
$(info ---- REGISTRY_FOR_DEPLOYER = $(REGISTRY_FOR_DEPLOYER))

app/build:: .build/deployer .build/elasticsearch

PHONY: app/test-install
app/test-install: app/build | app/setup
	export APP_DEPLOYER_IMAGE="$(APP_DEPLOYER_IMAGE)" \
	&& cat test.yaml.template | envsubst | kubectl create -f -

PHONY: app/test-uninstall
app/test-uninstall: app/build | app/setup
	export APP_DEPLOYER_IMAGE="$(APP_DEPLOYER_IMAGE)" \
	&& cat test.yaml.template | envsubst | kubectl delete -f -

PHONY: app/test-exec
app/test-exec: | app/setup
	kubectl exec -it exp /bin/sh

.build/deployer: deployer/* manifest/* $(MARKETPLACE_BASE_BUILD)/deployer-kubectl $(APP_BUILD)/registry_prefix | app/setup
	docker build \
	    --build-arg REGISTRY="$(REGISTRY_FOR_DEPLOYER)" \
	    --build-arg TAG="$(APP_TAG)" \
	    --build-arg MARKETPLACE_REGISTRY="$(MARKETPLACE_REGISTRY)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	gcloud docker -- push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/elasticsearch: $(APP_BUILD)/registry_prefix | app/setup
	gcloud docker -- pull launcher.gcr.io/google/elasticsearch5
	docker tag launcher.gcr.io/google/elasticsearch5 "$(APP_REGISTRY):$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY):$(APP_TAG)"
	@touch "$@"
