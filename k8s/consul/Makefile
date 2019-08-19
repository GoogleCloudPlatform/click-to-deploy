include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= consul

SOURCE_REGISTRY ?= marketplace.gcr.io/google

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/consul/VERSION` target to fill the RELEASE variable.
CONSUL_TAG ?= sha256:87d5efa7f6fa282a1c3c86ab12bf3928da8f779729ca3658170f1c907e522091
CONSUL_EXPORTER_TAG ?= sha256:e8ed2508dc84252243a5fbed256fc8bfa4dadf13b04a08d681f6b469e16cd646
METRICS_EXPORTER_TAG ?= v0.5.1

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 1.4
RELEASE ?= 1.4.4-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))
$(info ---- SOURCE_REGISTRY = $(SOURCE_REGISTRY))

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

app/build:: .build/consul/deployer \
            .build/consul/consul \
            .build/consul/consul-exporter \
            .build/consul/prometheus-to-sd \
            .build/consul/tester \
            .build/consul/VERSION


.build/consul: | .build
	mkdir -p "$@"


.PHONY: .build/consul/VERSION
.build/consul/VERSION:
	#exit 1


.build/consul/deployer: deployer/* \
                        chart/consul/* \
                        chart/consul/templates/* \
                        schema.yaml \
                        .build/var/APP_DEPLOYER_IMAGE \
                        .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                        .build/var/MARKETPLACE_TOOLS_TAG \
                        .build/var/REGISTRY \
                        .build/var/TRACK \
                        .build/var/RELEASE \
                        | .build/consul
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


.build/consul/consul: .build/var/REGISTRY \
                      .build/var/TRACK \
                      .build/var/RELEASE \
                      | .build/consul
	docker pull $(SOURCE_REGISTRY)/consul1@$(CONSUL_TAG)
	docker tag $(SOURCE_REGISTRY)/consul1@$(CONSUL_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/consul/consul-exporter: .build/var/REGISTRY \
                               .build/var/TRACK \
                               .build/var/RELEASE \
                               | .build/consul
	docker pull $(SOURCE_REGISTRY)/consul1/exporter@$(CONSUL_EXPORTER_TAG)
	docker tag $(SOURCE_REGISTRY)/consul1/exporter@$(CONSUL_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/consul-exporter:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/consul-exporter:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/consul-exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/consul-exporter:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/consul-exporter:$(RELEASE)"
	@touch "$@"


.build/consul/prometheus-to-sd: .build/var/REGISTRY \
                                .build/var/TRACK \
                                .build/var/RELEASE \
                                | .build/consul
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/consul/tester: .build/var/TESTER_IMAGE \
                      $(shell find apptest -type f) \
                      | .build/consul
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
