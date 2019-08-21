include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= etcd
SOURCE_REGISTRY ?= marketplace.gcr.io/google

ifndef SOURCE_IMAGE
  $(info ---- SOURCE_REGISTRY = $(SOURCE_REGISTRY))
endif

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/etcd/VERSION` target to fill the RELEASE variable.
ETCD_TAG ?= sha256:fa54bc0e71f1f3a1fd3a0c8d9b66cd959ef9292bdd3a829d48de58a9a87e8989
METRICS_EXPORTER_TAG ?= v0.5.1
SOURCE_IMAGE ?= $(SOURCE_REGISTRY)/etcd3@$(ETCD_TAG)


BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 3.3
RELEASE ?= 3.3.13-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))
$(info ---- SOURCE_IMAGE = $(SOURCE_IMAGE))
$(info ---- APP_IMAGE = $(REGISTRY)/$(APP_ID):$(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

ifdef REPLICAS
  REPLICAS_FIELD = , "replicas": $(REPLICAS)
endif


APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(REPLICAS_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/etcd/deployer \
            .build/etcd/etcd \
            .build/etcd/prometheus-to-sd \
            .build/etcd/tester \
            .build/etcd/VERSION


.build/etcd: | .build
	mkdir -p "$@"


.PHONY: .build/etcd/VERSION
.build/etcd/VERSION:
	# exit 1


.build/etcd/deployer: deployer/* \
                      chart/etcd/* \
                      chart/etcd/templates/* \
                      schema.yaml \
                      .build/var/APP_DEPLOYER_IMAGE \
                      .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                      .build/var/MARKETPLACE_TOOLS_TAG \
                      .build/var/REGISTRY \
                      .build/var/TRACK \
                      .build/var/RELEASE \
                      | .build/etcd
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


.build/etcd/etcd: .build/var/REGISTRY \
                  .build/var/TRACK \
                  .build/var/RELEASE \
                  | .build/etcd
	docker pull $(SOURCE_IMAGE)
	docker tag $(SOURCE_IMAGE) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/etcd/prometheus-to-sd: .build/var/REGISTRY \
                              .build/var/TRACK \
                              .build/var/RELEASE \
                              | .build/etcd
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/etcd/tester: .build/var/TESTER_IMAGE \
                    $(shell find apptest -type f) \
                    | .build/etcd
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
