include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 5.3
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/grafana/deployer:$(TAG)
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

TESTER_IMAGE ?= $(REGISTRY)/grafana/tester:$(TAG)


app/build:: .build/grafana/deployer \
            .build/grafana/grafana \
            .build/grafana/debian9 \
            .build/grafana/prometheus-to-sd \
            .build/grafana/tester


.build/grafana: | .build
	mkdir -p "$@"


.build/grafana/deployer: deployer/* \
                         chart/grafana/* \
                         chart/grafana/templates/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/grafana
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/grafana" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/grafana/grafana: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/grafana
	docker pull marketplace.gcr.io/google/grafana5:$(TAG)
	docker tag marketplace.gcr.io/google/grafana5:$(TAG) \
	    "$(REGISTRY)/grafana:$(TAG)"
	docker push "$(REGISTRY)/grafana:$(TAG)"
	@touch "$@"


.build/grafana/debian9: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/grafana
	docker pull marketplace.gcr.io/google/debian9:latest
	docker tag marketplace.gcr.io/google/debian9:latest \
	    "$(REGISTRY)/grafana/debian9:$(TAG)"
	docker push "$(REGISTRY)/grafana/debian9:$(TAG)"
	@touch "$@"


.build/grafana/prometheus-to-sd: .build/var/REGISTRY \
                                 .build/var/TAG \
                                 | .build/grafana
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/grafana/prometheus-to-sd:$(TAG)"
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
