APP_NAME = wordpress

tools_path = ../vendor/marketplace-tools

include $(tools_path)/gcloud.Makefile

include $(tools_path)/crd.Makefile
include $(tools_path)/app.Makefile
include $(tools_path)/ubbagent.Makefile

app/build:: .build/deployer .build/wordpress .build/init .build/mysql .build/controller .build/ubbagent

.build/deployer: deployer/* manifest/* $(MARKETPLACE_BASE_BUILD)/deployer-kubectl .build/controller $(APP_BUILD)/registry_prefix | app/setup
	docker build \
	    --build-arg REGISTRY="$(APP_REGISTRY)" \
	    --build-arg TAG="$(APP_TAG)" \
	    --build-arg MARKETPLACE_REGISTRY="$(MARKETPLACE_REGISTRY)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	gcloud docker -- push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/wordpress: $(APP_BUILD)/registry_prefix | app/setup
	gcloud docker -- pull launcher.gcr.io/google/wordpress4-php5-apache
	docker tag launcher.gcr.io/google/wordpress4-php5-apache "$(APP_REGISTRY):$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY):$(APP_TAG)"
	@touch "$@"

# Build secondary app image.
.build/init: init/* $(APP_BUILD)/registry_prefix | app/setup
	cd init \
	&& docker build --tag "$(APP_REGISTRY)/init:$(APP_TAG)" .
	gcloud docker -- push "$(APP_REGISTRY)/init:$(APP_TAG)"
	@touch "$@"

# Relocate public mysql image to $APP_REGISTRY.
.build/mysql: $(APP_BUILD)/registry_prefix | app/setup
	gcloud docker -- pull launcher.gcr.io/google/mysql5
	docker tag launcher.gcr.io/google/mysql5 "$(APP_REGISTRY)/mysql:$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY)/mysql:$(APP_TAG)"
	@touch "$@"

# Relocate public controller image to $APP_REGISTRY.
.build/controller: $(APP_BUILD)/registry_prefix $(MARKETPLACE_BASE_BUILD)/controller | app/setup
	gcloud docker -- pull "$(MARKETPLACE_REGISTRY)/controller"
	docker tag "$(MARKETPLACE_REGISTRY)/controller" "$(APP_REGISTRY)/controller:$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY)/controller:$(APP_TAG)"
	@touch "$@"

# Relocate public ubbagent image to $APP_REGISTRY.
.build/ubbagent: $(APP_BUILD)/registry_prefix $(UBBAGENT_BUILD)/ubbagent | app/setup
	gcloud docker -- pull "$(MARKETPLACE_REGISTRY)/ubbagent"
	docker tag "$(MARKETPLACE_REGISTRY)/ubbagent" "$(APP_REGISTRY)/ubbagent:$(APP_TAG)"
	gcloud docker -- push "$(APP_REGISTRY)/ubbagent:$(APP_TAG)"
	@touch "$@"
