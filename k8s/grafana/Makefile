include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 5.3
RELEASE ?= 5.3.4
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/grafana/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/grafana/deployer:$(TAG)
APP_GCS_PATH ?= $(GCS_URL)/grafana:$(TAG)

NAME ?= grafana-1

ifdef IMAGE_GRAFANA
  IMAGE_GRAFANA_FIELD = , "grafana.image": "$(IMAGE_GRAFANA)"
endif

ifdef IMAGE_GRAFANA_INIT
  IMAGE_GRAFANA_INIT_FIELD = , "grafana.initImage": "$(IMAGE_GRAFANA_INIT)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_GRAFANA_FIELD) \
  $(IMAGE_GRAFANA_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

include ../app_v2.Makefile

TESTER_IMAGE ?= $(REGISTRY)/grafana/tester:$(TAG)


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
	    --build-arg RELEASE="$(RELEASE)" \
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
	docker pull marketplace.gcr.io/google/grafana5:$(RELEASE)
	docker tag marketplace.gcr.io/google/grafana5:$(RELEASE) "$(REGISTRY)/grafana:$(RELEASE)"
	docker tag "$(REGISTRY)/grafana:$(RELEASE)" "$(REGISTRY)/grafana:$(TAG)"
	docker push "$(REGISTRY)/grafana:$(RELEASE)"
	docker push "$(REGISTRY)/grafana:$(TAG)"
	@touch "$@"


.build/grafana/debian9: .build/var/REGISTRY \
                        .build/var/TAG \
			.build/var/RELEASE \
                        | .build/grafana
	docker pull marketplace.gcr.io/google/debian9
	docker tag marketplace.gcr.io/google/debian9 "$(REGISTRY)/grafana/debian9:$(RELEASE)"
	docker tag "$(REGISTRY)/grafana/debian9:$(RELEASE)" "$(REGISTRY)/grafana/debian9:$(TAG)"
	docker push "$(REGISTRY)/grafana/debian9:$(RELEASE)"
	docker push "$(REGISTRY)/grafana/debian9:$(TAG)"
	@touch "$@"


.build/grafana/prometheus-to-sd: .build/var/REGISTRY \
                                 .build/var/TAG \
                                 | .build/grafana
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/grafana/prometheus-to-sd:$(RELEASE)"
	docker tag "$(REGISTRY)/grafana/prometheus-to-sd:$(RELEASE)" \
	    "$(REGISTRY)/grafana/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/grafana/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/grafana/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/grafana/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/grafana
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
