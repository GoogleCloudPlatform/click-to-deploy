TAG ?= 3.0
SOURCE_REGISTRY ?= gcr.io/gatekeeper-marketplace

# Convenience makefiles.
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= gatekeeper
GATEKEEPER_IMAGE ?= $(SOURCE_REGISTRY)/$(APP_ID):$(TAG)
NAME ?= gatekeeper
AUDIT_INTERVAL ?= 60
APP_PARAMETERS ?= { \
	"name": "$(NAME)", \
	"namespace": "$(NAMESPACE)", \
	"auditInterval": "$(AUDIT_INTERVAL)" \
}

TESTER_IMAGE ?= $(REGISTRY)/gatekeeper/deployer/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
	"imageTester": "$(TESTER_IMAGE)" \
}

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 3.0
RELEASE ?= 3.0.4-beta.1-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

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

.build/app: | .build
	mkdir -p "$@"

# Overwriting parent to change gcr path -- remove when done using staging
.PHONY: .build/app/dev
.build/app/dev: .build/var/MARKETPLACE_TOOLS_TAG \
							| .build/app
	@docker run \
        "gcr.io/cloud-marketplace-staging/marketplace-k8s-app-tools/k8s/dev:unreleased-pr396" \
        cat /scripts/dev > "/tmp/dev"
	@mv "/tmp/dev" "$@"
	@chmod a+x "$@"

.build/gatekeeper: | .build
	mkdir -p "$@"

.build/gatekeeper/deployer: deployer/* \
                            chart/gatekeeper/* \
                            chart/gatekeeper/templates/* \
                            schema.yaml \
                            .build/var/APP_DEPLOYER_IMAGE \
                            .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                            .build/var/MARKETPLACE_TOOLS_TAG \
                            .build/var/REGISTRY \
                            .build/var/TAG \
                            .build/var/TRACK \
                            .build/var/RELEASE \
                            licenses \
                            | .build/gatekeeper
	$(call print_target, $@)
	docker build \
			--build-arg REGISTRY="$(REGISTRY)/gatekeeper" \
			--build-arg TAG="$(TAG)" \
			--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
			--tag "$(APP_DEPLOYER_IMAGE)" \
			-f deployer/Dockerfile \
			.

	docker tag "$(APP_DEPLOYER_IMAGE)" "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/gatekeeper/tester: .build/var/TESTER_IMAGE
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"

.build/gatekeeper/gatekeeper: .build/var/REGISTRY \
                                .build/var/TAG \
                              | .build/gatekeeper
	$(call print_target, $@)
	# The main image is assumed to be already placed in the right location
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
