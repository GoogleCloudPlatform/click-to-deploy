include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 6.3
METRICS_EXPORTER_TAG ?= v0.5.1
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/elasticsearch/deployer:$(TAG)
NAME ?= elasticsearch-1

ifdef REPLICAS
  REPLICAS_FIELD = , "elasticsearch.replicas": "$(REPLICAS)"
endif

ifdef IMAGE_ELASTICSEARCH
  IMAGE_ELASTICSEARCH_FIELD = , "elasticsearch.image": "$(IMAGE_ELASTICSEARCH)"
endif

ifdef IMAGE_INIT
  IMAGE_INIT_FIELD = , "elasticsearch.initImage": "$(IMAGE_INIT)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(REPLICAS_FIELD) \
  $(IMAGE_ELASTICSEARCH_FIELD) \
  $(IMAGE_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/elasticsearch/tester:$(TAG)


app/build:: .build/elasticsearch/elasticsearch \
            .build/elasticsearch/deployer \
            .build/elasticsearch/ubuntu16_04 \
            .build/elasticsearch/prometheus-to-sd \
            .build/elasticsearch/tester

.build/elasticsearch: | .build
	mkdir -p "$@"


.build/elasticsearch/deployer: deployer/* \
                               chart/elasticsearch/* \
                               chart/elasticsearch/templates/* \
                               schema.yaml \
                               .build/var/APP_DEPLOYER_IMAGE \
                               .build/var/MARKETPLACE_TOOLS_TAG \
                               .build/var/REGISTRY \
                               .build/var/TAG \
                               | .build/elasticsearch
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/elasticsearch" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/elasticsearch/elasticsearch: .build/var/REGISTRY \
                                    .build/var/TAG \
                                    | .build/elasticsearch
	docker pull marketplace.gcr.io/google/elasticsearch6:$(TAG)
	docker tag marketplace.gcr.io/google/elasticsearch6:$(TAG) \
	    "$(REGISTRY)/elasticsearch:$(TAG)"
	docker push "$(REGISTRY)/elasticsearch:$(TAG)"
	@touch "$@"


.build/elasticsearch/ubuntu16_04: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/elasticsearch
	docker pull marketplace.gcr.io/google/ubuntu16_04
	docker tag marketplace.gcr.io/google/ubuntu16_04 \
	    "$(REGISTRY)/elasticsearch/ubuntu16_04:$(TAG)"
	docker push "$(REGISTRY)/elasticsearch/ubuntu16_04:$(TAG)"
	@touch "$@"

.build/elasticsearch/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   | .build/elasticsearch
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/elasticsearch/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/elasticsearch/prometheus-to-sd:$(TAG)"
	@touch "$@"

.build/elasticsearch/tester: .build/var/TESTER_IMAGE \
                             $(shell find apptest -type f) \
                             | .build/elasticsearch
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
