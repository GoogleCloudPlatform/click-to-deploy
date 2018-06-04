APP_NAME = elasticsearch

APP_PARAMETERS ?= {"APP_INSTANCE_NAME": "$(APP_INSTANCE_NAME)", "NAMESPACE": "$(NAMESPACE)", "REPLICAS": "2"}

tools_path = ../vendor/marketplace-tools

include $(tools_path)/gcloud.Makefile

include $(tools_path)/crd.Makefile
include $(tools_path)/app.Makefile
include $(tools_path)/ubbagent.Makefile

REGISTRY_FOR_DEPLOYER ?= $(APP_REGISTRY)
$(info ---- REGISTRY_FOR_DEPLOYER = $(REGISTRY_FOR_DEPLOYER))


app/build:: .build/deployer .build/ubuntu16_04 .build/elasticsearch

.build/deployer: deployer/* manifest/* $(MARKETPLACE_BASE_BUILD)/deployer-kubectl $(APP_BUILD)/registry_prefix | app/setup
	docker build \
	    --build-arg REGISTRY="$(REGISTRY_FOR_DEPLOYER)" \
	    --build-arg TAG="$(APP_TAG)" \
	    --build-arg MARKETPLACE_REGISTRY="$(MARKETPLACE_REGISTRY)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

# Relocate public ubuntu16_04 image to $APP_REGISTRY.
.build/ubuntu16_04: $(APP_BUILD)/registry_prefix | app/setup
	docker pull launcher.gcr.io/google/ubuntu16_04
	docker tag launcher.gcr.io/google/ubuntu16_04 "$(APP_REGISTRY)/ubuntu16_04:$(APP_TAG)"
	docker push "$(APP_REGISTRY)/ubuntu16_04:$(APP_TAG)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/elasticsearch: $(APP_BUILD)/registry_prefix | app/setup
	#docker pull launcher.gcr.io/google/elasticsearch6
	#docker tag launcher.gcr.io/google/elasticsearch6 "$(APP_REGISTRY):$(APP_TAG)"
	docker tag my-elasticsearch-6 "$(APP_REGISTRY):$(APP_TAG)"
	docker push "$(APP_REGISTRY):$(APP_TAG)"
	@touch "$@"
