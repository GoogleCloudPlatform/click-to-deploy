include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= jenkins-managed-updates
VERIFY_WAIT_TIMEOUT = 1800

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/jenkins/VERSION` target to fill the RELEASE variable.
JENKINS_TAG ?= sha256:57037c8bcdb148890ca3faa4b66dc5a6487ac64d8383f210444e731eefe4a2ea

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 2.176
RELEASE ?= 2.176.1-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/jenkins/deployer \
            .build/jenkins/jenkins \
            .build/jenkins/tester \
            .build/jenkins/VERSION


.build/jenkins: | .build
	mkdir -p "$@"


.PHONY: .build/jenkins/VERSION
.build/jenkins/VERSION:
	docker run --rm --entrypoint=printenv marketplace.gcr.io/google/jenkins2@$(JENKINS_TAG) JENKINS_VERSION


.build/jenkins/deployer: deployer/* \
                         chart/jenkins/* \
                         chart/jenkins/templates/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TRACK \
                         .build/var/RELEASE \
                         | .build/jenkins
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/$(APP_ID)" \
	    --build-arg TAG="$(RELEASE)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker tag "$(APP_DEPLOYER_IMAGE)" "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/jenkins/jenkins: .build/var/REGISTRY \
                        .build/var/TRACK \
                        .build/var/RELEASE \
                        | .build/jenkins
	docker pull marketplace.gcr.io/google/jenkins2@$(JENKINS_TAG)
	docker tag marketplace.gcr.io/google/jenkins2@$(JENKINS_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/jenkins/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/jenkins
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
