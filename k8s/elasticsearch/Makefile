APP_NAME = elasticsearch

tools_path = ../vendor/marketplace-tools

include $(tools_path)/gcloud.Makefile

include $(tools_path)/crd.Makefile
include $(tools_path)/app.Makefile
include $(tools_path)/ubbagent.Makefile

app/build:: .build/deployer

.build/deployer: deployer/* manifest/* $(MARKETPLACE_BASE_BUILD)/deployer-kubectl .build/controller $(APP_BUILD)/registry_prefix | app/setup
	docker build \
	    --build-arg MARKETPLACE_REGISTRY="$(MARKETPLACE_REGISTRY)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	gcloud docker -- push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

# Relocate public controller image to $APP_REGISTRY.
.build/controller: $(APP_BUILD)/registry_prefix $(MARKETPLACE_BASE_BUILD)/controller | app/setup
	gcloud docker -- pull "$(MARKETPLACE_REGISTRY)/controller"
	docker tag "$(MARKETPLACE_REGISTRY)/controller" "$(APP_REGISTRY)/controller:$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY)/controller:$(APP_TAG)"
	@touch "$@"
