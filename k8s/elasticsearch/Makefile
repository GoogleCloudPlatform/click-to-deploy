APP_NAME = elasticsearch

tools_path = ../vendor/marketplace-tools

include $(tools_path)/gcloud.Makefile

include $(tools_path)/crd.Makefile
include $(tools_path)/app.Makefile
include $(tools_path)/ubbagent.Makefile

REGISTRY_FOR_DEPLOYER ?= $(APP_REGISTRY)
$(info ---- REGISTRY_FOR_DEPLOYER = $(REGISTRY_FOR_DEPLOYER))

app/build:: .build/deployer .build/debian9 .build/elasticsearch

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

# Relocate public debian9 image to $APP_REGISTRY.
.build/debian9: $(APP_BUILD)/registry_prefix | app/setup
	gcloud docker -- pull launcher.gcr.io/google/debian9
	docker tag launcher.gcr.io/google/debian9 "$(APP_REGISTRY)/debian9:$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY)/debian9:$(APP_TAG)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/elasticsearch: $(APP_BUILD)/registry_prefix | app/setup
	gcloud docker -- pull launcher.gcr.io/google/elasticsearch5
	docker tag launcher.gcr.io/google/elasticsearch5 "$(APP_REGISTRY):$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY):$(APP_TAG)"
	@touch "$@"
