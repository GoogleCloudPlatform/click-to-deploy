include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= zookeeper
WAIT_FOR_READY_TIMEOUT = 600

SOURCE_REGISTRY ?= marketplace.gcr.io/google

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/zookeeper/VERSION` target to fill the RELEASE variable.
ZK_TAG ?= sha256:707f3645bc82f95337ccb156d5f5c1acb46353714bbf5d348cff3daf9cb29318
ZK_EXPORTER_TAG ?= exporter
METRICS_EXPORTER_TAG ?= v0.5.1

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 3.4
RELEASE ?= 3.4.14-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/zookeeper/deployer \
            .build/zookeeper/zookeeper \
            .build/zookeeper/exporter \
            .build/zookeeper/prometheus-to-sd \
            .build/zookeeper/tester \
            .build/zookeeper/VERSION


.build/zookeeper: | .build
	mkdir -p "$@"


.PHONY: .build/zookeeper/VERSION
.build/zookeeper/VERSION:
	docker run --rm --entrypoint=printenv $(SOURCE_REGISTRY)/zookeeper3@$(ZK_TAG) ZK_VERSION


.build/zookeeper/deployer: deployer/* \
                           chart/zookeeper/* \
                           chart/zookeeper/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TRACK \
                           .build/var/RELEASE \
                           | .build/zookeeper
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


.build/zookeeper/zookeeper: .build/var/REGISTRY \
                            .build/var/TRACK \
                            .build/var/RELEASE \
                            | .build/zookeeper
	docker pull $(SOURCE_REGISTRY)/zookeeper3@$(ZK_TAG)
	docker tag $(SOURCE_REGISTRY)/zookeeper3@$(ZK_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/zookeeper/exporter: .build/var/REGISTRY \
                           .build/var/TRACK \
                           .build/var/RELEASE \
                           | .build/zookeeper
	docker pull $(SOURCE_REGISTRY)/zookeeper3:$(ZK_EXPORTER_TAG)
	docker tag $(SOURCE_REGISTRY)/zookeeper3:$(ZK_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/exporter:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/exporter:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/exporter:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/exporter:$(RELEASE)"
	@touch "$@"


.build/zookeeper/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TRACK \
                                   .build/var/RELEASE \
                                   | .build/zookeeper
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/zookeeper/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/zookeeper
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
