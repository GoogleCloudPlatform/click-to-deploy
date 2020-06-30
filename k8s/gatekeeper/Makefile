# Convenience makefiles.
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

CHART_NAME := gatekeeper
APP_ID ?= $(CHART_NAME)
SOURCE_REGISTRY ?= gcr.io/gatekeeper-marketplace
NAME ?= $(CHART_NAME)

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

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer/tester:$(TRACK)
APP_TEST_PARAMETERS ?= { \
	"testerImage": "$(TESTER_IMAGE)" \
}


APP_IMAGE ?= $(REGISTRY)/$(APP_ID):$(RELEASE)
APP_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID):$(TRACK)

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)


IMAGE_MAIN ?= $(SOURCE_REGISTRY)/gatekeeper:$(TRACK)
# Main image
image-$(CHART_NAME) ?= $(call get_sha256,$(IMAGE_MAIN))

# app_v2.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

# Build tester image
app/build:: .build/$(CHART_NAME)/tester

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
