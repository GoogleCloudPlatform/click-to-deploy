include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 1.7
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/influxdb/deployer:$(TAG)
NAME ?= influxdb-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/influxdb/tester:$(TAG)


app/build:: .build/influxdb/deployer \
            .build/influxdb/influxdb \
            .build/influxdb/prometheus-to-sd \
            .build/influxdb/tester


.build/influxdb: | .build
	mkdir -p "$@"


.build/influxdb/deployer: deployer/* \
                          chart/influxdb/* \
                          chart/influxdb/templates/* \
                          schema.yaml \
                          .build/var/APP_DEPLOYER_IMAGE \
                          .build/var/MARKETPLACE_TOOLS_TAG \
                          .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/influxdb
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/influxdb" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/influxdb/influxdb: .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/influxdb
	docker pull marketplace.gcr.io/google/influxdb1:$(TAG)
	docker tag marketplace.gcr.io/google/influxdb1:$(TAG) \
	    "$(REGISTRY)/influxdb:$(TAG)"
	docker push "$(REGISTRY)/influxdb:$(TAG)"
	@touch "$@"


.build/influxdb/prometheus-to-sd: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/influxdb
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/influxdb/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/influxdb/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/influxdb/tester: .build/var/TESTER_IMAGE \
                        $(shell find apptest -type f) \
                        | .build/influxdb
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
