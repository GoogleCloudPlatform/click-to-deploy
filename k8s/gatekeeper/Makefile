# Convenience makefiles.
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= gatekeeper
SOURCE_REGISTRY ?= gcr.io/gatekeeper-marketplace
NAME ?= gatekeeper

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 3.0
RELEASE ?= 3.0.4-beta.1-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

GATEKEEPER_IMAGE ?= $(SOURCE_REGISTRY)/$(APP_ID):$(TRACK)
AUDIT_INTERVAL ?= 60
APP_PARAMETERS ?= { \
	"name": "$(NAME)", \
	"namespace": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/gatekeeper/deployer/tester:$(TRACK)
APP_TEST_PARAMETERS ?= { \
	"imageTester": "$(TESTER_IMAGE)" \
}


APP_IMAGE ?= $(REGISTRY)/$(APP_ID):$(RELEASE)
APP_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID):$(TRACK)

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile


# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/gatekeeper/deployer \
			.build/gatekeeper/tester \
			.build/gatekeeper/gatekeeper

.build/gatekeeper: | .build
	mkdir -p "$@"


.build/gatekeeper/gatekeeper: .build/var/REGISTRY \
                              | .build/gatekeeper
	$(call print_target, $@)
	docker pull gcr.io/gatekeeper-marketplace/gatekeeper:$(TRACK)
	docker tag gcr.io/gatekeeper-marketplace/gatekeeper:$(TRACK) \
	    "$(APP_IMAGE)"
	docker tag gcr.io/gatekeeper-marketplace/gatekeeper:$(TRACK) \
	    "$(APP_IMAGE_TRACK_TAG)"
	docker push "$(APP_IMAGE)"
	docker push "$(APP_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/gatekeeper/deployer: deployer/* \
                            chart/gatekeeper/* \
                            chart/gatekeeper/templates/* \
                            schema.yaml \
                            .build/var/APP_DEPLOYER_IMAGE \
                            .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                            .build/var/MARKETPLACE_TOOLS_TAG \
                            .build/var/REGISTRY \
                            .build/var/TRACK \
                            .build/var/RELEASE \
                            licenses \
                            | .build/gatekeeper
	$(call print_target, $@)
	docker build \
			--build-arg REGISTRY="$(REGISTRY)/gatekeeper" \
			--build-arg TAG="$(RELEASE)" \
			--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
			--tag "$(APP_DEPLOYER_IMAGE)" \
			-f deployer/Dockerfile \
			.

	docker tag "$(APP_DEPLOYER_IMAGE)" "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/gatekeeper/tester: .build/var/TESTER_IMAGE \
                    $(shell find apptest -type f) \
                    | .build/gatekeeper
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


# concatenate all licenses together
licenses:
	$(call print_target, $@)
	rm -rf .build/licenses
	mkdir -p .build/licenses
	cp ../../LICENSE .build/licenses/.
	echo >> .build/licenses/LICENSE
	echo '-----' >> .build/licenses/LICENSE
	echo >> .build/licenses/LICENSE
	cat licenses_for_manifest/LICENSE >> .build/licenses/LICENSE
