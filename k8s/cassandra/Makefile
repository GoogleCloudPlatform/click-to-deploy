include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= cassandra-managed-updates
VERIFY_WAIT_TIMEOUT = 1800

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/cassandra/VERSION` target to fill the RELEASE variable.
CASSANDRA_TAG ?= sha256:38f4a15b2c6ee559c30d167becbfb2ba8e6ccd476c36a2154a88e12824a7fcf0
METRICS_EXPORTER_TAG ?= v0.5.1

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 3.11
RELEASE ?= 3.11.4-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef REPLICAS
  REPLICAS_FIELD = , "cassandra.replicas": "$(REPLICAS)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(REPLICAS_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/cassandra/deployer \
            .build/cassandra/cassandra \
            .build/cassandra/prometheus-to-sd \
            .build/cassandra/tester \
            .build/cassandra/VERSION


.build/cassandra: | .build
	mkdir -p "$@"


.PHONY: .build/cassandra/VERSION
.build/cassandra/VERSION:
	docker run --rm --entrypoint=printenv marketplace.gcr.io/google/cassandra3@$(CASSANDRA_TAG) CASSANDRA_VERSION


.build/cassandra/deployer: deployer/* \
                           chart/cassandra/* \
                           chart/cassandra/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TRACK \
                           .build/var/RELEASE \
                           | .build/cassandra
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


.build/cassandra/cassandra: .build/var/REGISTRY \
                            .build/var/TRACK \
                            .build/var/RELEASE \
                            | .build/cassandra
	docker pull marketplace.gcr.io/google/cassandra3@$(CASSANDRA_TAG)
	docker tag marketplace.gcr.io/google/cassandra3@$(CASSANDRA_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/cassandra/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TRACK \
                                   .build/var/RELEASE \
                                   | .build/cassandra
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/cassandra/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/cassandra
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
