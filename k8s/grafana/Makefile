include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 5.3
METRICS_EXPORTER_TAG ?= v0.5.1
RELEASE ?= 5.3.4

$(info ---- TAG = $(TAG))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/grafana/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/grafana/deployer:$(TAG)
APP_GCS_PATH ?= $(GCS_URL)/grafana/$(TAG)

NAME ?= grafana-1

ifdef IMAGE_GRAFANA_INIT
  IMAGE_GRAFANA_INIT_FIELD = , "grafana.initImage": "$(IMAGE_GRAFANA_INIT)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_GRAFANA_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/grafana/tester:$(TAG)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/grafana/debian9 \
            .build/grafana/deployer \
            .build/grafana/grafana \
            .build/grafana/prometheus-to-sd \
            .build/grafana/tester


.build/grafana: | .build
	mkdir -p "$@"


.build/grafana/deployer: deployer/* \
                         chart/grafana/* \
                         chart/grafana/templates/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         .build/var/RELEASE \
                         | .build/grafana
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/grafana" \
	    --build-arg TAG="$(RELEASE)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker tag "$(APP_DEPLOYER_IMAGE)" "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/grafana/grafana: .build/var/REGISTRY \
                        .build/var/TAG \
                        .build/var/RELEASE \
                        | .build/grafana
	docker pull marketplace.gcr.io/google/grafana5:$(TAG)
	docker tag marketplace.gcr.io/google/grafana5:$(TAG) "$(REGISTRY)/grafana:$(TAG)"
	docker tag "$(REGISTRY)/grafana:$(TAG)" "$(REGISTRY)/grafana:$(RELEASE)"
	docker push "$(REGISTRY)/grafana:$(TAG)"
	docker push "$(REGISTRY)/grafana:$(RELEASE)"
	@touch "$@"


.build/grafana/debian9: .build/var/REGISTRY \
                        .build/var/TAG \
                        .build/var/RELEASE \
                        | .build/grafana
	docker pull marketplace.gcr.io/google/debian9
	docker tag marketplace.gcr.io/google/debian9 "$(REGISTRY)/grafana/debian9:$(TAG)"
	docker tag "$(REGISTRY)/grafana/debian9:$(TAG)" "$(REGISTRY)/grafana/debian9:$(RELEASE)"
	docker push "$(REGISTRY)/grafana/debian9:$(TAG)"
	docker push "$(REGISTRY)/grafana/debian9:$(RELEASE)"
	@touch "$@"


.build/grafana/prometheus-to-sd: .build/var/REGISTRY \
                                 .build/var/TAG \
                                 .build/var/RELEASE \
                                 | .build/grafana
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/grafana/prometheus-to-sd:$(TAG)"
	docker tag "$(REGISTRY)/grafana/prometheus-to-sd:$(TAG)" \
	    "$(REGISTRY)/grafana/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/grafana/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/grafana/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/grafana/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/grafana
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
