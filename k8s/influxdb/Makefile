include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= influxdb-managed-updates

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/influxdb/VERSION` target to fill the RELEASE variable.
INFLUXDB_TAG ?= sha256:a41d33e302e917764d10f58dee6e7b89d764045468a30fa9eb31f5cb2c3bd6a8
METRICS_EXPORTER_TAG ?= v0.5.1

TIMESTAMP := $(shell date +%s)
TRACK ?= 1.7
RELEASE ?= 1.7.6-build.$(TIMESTAMP)

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

app/build:: .build/influxdb/deployer \
            .build/influxdb/influxdb \
            .build/influxdb/prometheus-to-sd \
            .build/influxdb/tester \
            .build/influxdb/VERSION


.build/influxdb: | .build
	mkdir -p "$@"


.PHONY: .build/influxdb/VERSION
.build/influxdb/VERSION:
	docker run --rm marketplace.gcr.io/google/influxdb1@$(INFLUXDB_TAG) influxd version


.build/influxdb/deployer: deployer/* \
                          chart/influxdb/* \
                          chart/influxdb/templates/* \
                          schema.yaml \
                          .build/var/APP_DEPLOYER_IMAGE \
                          .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                          .build/var/MARKETPLACE_TOOLS_TAG \
                          .build/var/REGISTRY \
                          .build/var/TRACK \
                          .build/var/RELEASE \
                          | .build/influxdb
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


.build/influxdb/influxdb: .build/var/REGISTRY \
                          .build/var/TRACK \
                          .build/var/RELEASE \
                          | .build/influxdb
	docker pull marketplace.gcr.io/google/influxdb1@$(INFLUXDB_TAG)
	docker tag marketplace.gcr.io/google/influxdb1@$(INFLUXDB_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/influxdb/prometheus-to-sd: .build/var/REGISTRY \
                                  .build/var/TRACK \
                                  .build/var/RELEASE \
                                  | .build/influxdb
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/influxdb/tester: .build/var/TESTER_IMAGE \
                        $(shell find apptest -type f) \
                        | .build/influxdb
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
