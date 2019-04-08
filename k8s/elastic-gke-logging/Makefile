include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

VERIFY_WAIT_TIMEOUT = 1200
ELASTICSEARCH_KIBANA_VERSION = 6.3
FLUENTD_VERSION = 1.2

TAG ?= $(ELASTICSEARCH_KIBANA_VERSION)
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/elastic-gke-logging/deployer:$(TAG)
NAME ?= elastic-gke-logging-1

ifdef ELASTICSEARCH_REPLICAS
  ELASTICSEARCH_REPLICAS_FIELD = , "elasticsearch.replicas": "$(ELASTICSEARCH_REPLICAS)"
endif

ifdef IMAGE_ELASTICSEARCH
  IMAGE_ELASTICSEARCH_FIELD = , "elasticsearch.image": "$(IMAGE_ELASTICSEARCH)"
endif

ifdef IMAGE_INIT
  IMAGE_INIT_FIELD = , "initImage": "$(IMAGE_INIT)"
endif

ifdef IMAGE_KIBANA
  IMAGE_KIBANA_FIELD = , "kibana.image": "$(IMAGE_KIBANA)"
endif

ifdef IMAGE_FLUENTD
  IMAGE_FLUENTD_FIELD = , "fluentd.image": "$(IMAGE_FLUENTD)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(ELASTICSEARCH_REPLICAS_FIELD) \
  $(IMAGE_ELASTICSEARCH_FIELD) \
  $(IMAGE_INIT_FIELD) \
  $(IMAGE_KIBANA_FIELD) \
  $(IMAGE_FLUENTD_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/elastic-gke-logging/tester:$(TAG)


app/build:: .build/elastic-gke-logging/elasticsearch \
            .build/elastic-gke-logging/kibana \
            .build/elastic-gke-logging/fluentd \
            .build/elastic-gke-logging/deployer \
            .build/elastic-gke-logging/ubuntu16_04 \
            .build/elastic-gke-logging/prometheus-to-sd \
            .build/elastic-gke-logging/tester


.build/elastic-gke-logging: | .build
	mkdir -p "$@"


.build/elastic-gke-logging/deployer: deployer/* \
                                     chart/elastic-gke-logging/* \
                                     chart/elastic-gke-logging/templates/* \
                                     schema.yaml \
                                     .build/var/APP_DEPLOYER_IMAGE \
                                     .build/var/MARKETPLACE_TOOLS_TAG \
                                     .build/var/REGISTRY \
                                     .build/var/TAG \
                                     | .build/elastic-gke-logging
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/elastic-gke-logging" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/elastic-gke-logging/elasticsearch: .build/var/REGISTRY \
                                          .build/var/TAG \
                                          | .build/elastic-gke-logging
	docker pull marketplace.gcr.io/google/elasticsearch6:$(ELASTICSEARCH_KIBANA_VERSION)
	docker tag marketplace.gcr.io/google/elasticsearch6:$(ELASTICSEARCH_KIBANA_VERSION) \
	    "$(REGISTRY)/elastic-gke-logging:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/kibana: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   | .build/elastic-gke-logging
	docker pull marketplace.gcr.io/google/kibana6:$(ELASTICSEARCH_KIBANA_VERSION)
	docker tag marketplace.gcr.io/google/kibana6:$(ELASTICSEARCH_KIBANA_VERSION) \
	    "$(REGISTRY)/elastic-gke-logging/kibana:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging/kibana:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/fluentd: .build/var/REGISTRY \
                                    .build/var/TAG \
                                    | .build/elastic-gke-logging
	docker pull marketplace.gcr.io/google/fluentd1:$(FLUENTD_VERSION)
	docker tag marketplace.gcr.io/google/fluentd1:$(FLUENTD_VERSION) \
	    "$(REGISTRY)/elastic-gke-logging/fluentd:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging/fluentd:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/ubuntu16_04: .build/var/REGISTRY \
                                        .build/var/TAG \
                                        | .build/elastic-gke-logging
	docker pull marketplace.gcr.io/google/ubuntu16_04
	docker tag marketplace.gcr.io/google/ubuntu16_04 \
	    "$(REGISTRY)/elastic-gke-logging/ubuntu16_04:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging/ubuntu16_04:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/prometheus-to-sd: .build/var/REGISTRY \
                                             .build/var/TAG \
                                             | .build/elastic-gke-logging
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/elastic-gke-logging/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/tester: .build/var/TESTER_IMAGE \
                                   $(shell find apptest -type f) \
                                   | .build/elastic-gke-logging
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
