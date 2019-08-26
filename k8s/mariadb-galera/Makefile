include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= mariadb-galera
VERIFY_WAIT_TIMEOUT = 1800

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/mariadb-galera/VERSION` target to fill the RELEASE variable.
MARIADB_TAG ?= sha256:a732af2cfccacefbfdc563a46366546af559fa0c81b33c08cc08ccb95fbce3de
METRICS_EXPORTER_TAG ?= v0.5.1
PEER_FINDER_TAG ?= latest

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 10.3
RELEASE ?= 10.3.17-$(BUILD_ID)

# ===== to move =====
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

SOURCE_REGISTRY ?= marketplace.gcr.io/google
# ===== end to move =====

# Images
IMAGE_MARIADB ?= $(SOURCE_REGISTRY)/mariadb10@$(MARIADB_TAG)
IMAGE_MARIADB_EXPORTER ?= $(SOURCE_REGISTRY)/mysql5:exporter
IMAGE_PEER_FINDER ?= $(SOURCE_REGISTRY)/peer-finder0:$(PEER_FINDER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "prometheusToSd.enabled": $(METRICS_EXPORTER_ENABLED)
endif

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))
$(info ---- APP IMAGE = $(IMAGE_MARIADB))

NAME ?= $(APP_ID)-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/$(APP_ID)/deployer \
            .build/$(APP_ID)/$(APP_ID) \
            .build/$(APP_ID)/mysqld-exporter \
            .build/$(APP_ID)/prometheus-to-sd \
            .build/$(APP_ID)/peer-finder \
            .build/$(APP_ID)/tester \
            .build/$(APP_ID)/VERSION


.build/$(APP_ID): | .build
	mkdir -p "$@"


.PHONY: .build/$(APP_ID)/VERSION
.build/$(APP_ID)/VERSION:
	docker run --rm --entrypoint=printenv $(IMAGE_MARIADB) MARIADB_VERSION \
	    | awk -F'[+:]' '{ print $$2 }'


.build/$(APP_ID)/deployer: deployer/* \
                                chart/$(APP_ID)/* \
                                chart/$(APP_ID)/templates/* \
                                schema.yaml \
                                .build/var/APP_DEPLOYER_IMAGE \
                                .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                                .build/var/MARKETPLACE_TOOLS_TAG \
                                .build/var/REGISTRY \
                                .build/var/TRACK \
                                .build/var/RELEASE \
                                | .build/$(APP_ID)
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


.build/$(APP_ID)/$(APP_ID): .build/var/REGISTRY \
                                      .build/var/TRACK \
                                      .build/var/RELEASE \
                                      | .build/$(APP_ID)
	docker pull $(IMAGE_MARIADB)
	docker tag $(IMAGE_MARIADB) "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/$(APP_ID)/mysqld-exporter: .build/var/REGISTRY \
                                       .build/var/TRACK \
                                       .build/var/RELEASE \
                                       | .build/$(APP_ID)
	docker pull $(IMAGE_MARIADB_EXPORTER)
	docker tag $(IMAGE_MARIADB_EXPORTER) \
	    "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	@touch "$@"


.build/$(APP_ID)/prometheus-to-sd: .build/var/REGISTRY \
                                        .build/var/TRACK \
                                        .build/var/RELEASE \
                                        | .build/$(APP_ID)
	docker pull $(IMAGE_PROMETHEUS_TO_SD)
	docker tag $(IMAGE_PROMETHEUS_TO_SD) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/$(APP_ID)/peer-finder: .build/var/REGISTRY \
                                   .build/var/TRACK \
                                   .build/var/RELEASE \
                                   | .build/$(APP_ID)
	docker pull $(IMAGE_PEER_FINDER)
	docker tag $(IMAGE_PEER_FINDER) \
	    "$(REGISTRY)/$(APP_ID)/peer-finder:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/peer-finder:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/peer-finder:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/peer-finder:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/peer-finder:$(RELEASE)"
	@touch "$@"


.build/$(APP_ID)/tester: .build/var/TESTER_IMAGE \
                              $(shell find apptest -type f) \
                              | .build/$(APP_ID)
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
