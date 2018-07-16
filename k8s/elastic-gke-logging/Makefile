include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


ELASTICSEARCH_KIBANA_VERSION = 6.3
FLUENTD_VERSION = 1.2

TAG ?= $(ELASTICSEARCH_KIBANA_VERSION)
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/elastic-gke-logging/deployer:$(TAG)
NAME ?= elastic-gke-logging-1

ifdef ELASTICSEARCH_REPLICAS
  ELASTICSEARCH_REPLICAS_FIELD = , "ELASTICSEARCH_REPLICAS": "$(ELASTICSEARCH_REPLICAS)"
endif

ifdef IMAGE_ELASTICSEARCH
  IMAGE_ELASTICSEARCH_FIELD = , "IMAGE_ELASTICSEARCH": "$(IMAGE_ELASTICSEARCH)"
endif

ifdef IMAGE_INIT
  IMAGE_INIT_FIELD = , "IMAGE_INIT": "$(IMAGE_INIT)"
endif

ifdef IMAGE_KIBANA
  IMAGE_KIBANA_FIELD = , "IMAGE_KIBANA": "$(IMAGE_KIBANA)"
endif

ifdef IMAGE_FLUENTD
  IMAGE_FLUENTD_FIELD = , "IMAGE_FLUENTD": "$(IMAGE_FLUENTD)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(ELASTICSEARCH_REPLICAS_FIELD) \
  $(IMAGE_ELASTICSEARCH_FIELD) \
	$(IMAGE_INIT_FIELD) \
  $(IMAGE_KIBANA_FIELD) \
  $(IMAGE_FLUENTD_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/elastic-gke-logging/elasticsearch \
            .build/elastic-gke-logging/kibana \
            .build/elastic-gke-logging/fluentd \
            .build/elastic-gke-logging/deployer \
            .build/elastic-gke-logging/ubuntu16_04


.build/elastic-gke-logging: | .build
	mkdir -p "$@"


.build/elastic-gke-logging/deployer: deployer/* \
                                     manifest/* \
                                     .build/var/APP_DEPLOYER_IMAGE \
                                     .build/var/REGISTRY \
                                     .build/var/TAG \
                                     | .build/elastic-gke-logging
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/elastic-gke-logging" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/elastic-gke-logging/elasticsearch: .build/var/REGISTRY \
                                          .build/var/TAG \
                                          | .build/elastic-gke-logging
	docker pull launcher.gcr.io/google/elasticsearch6:$(ELASTICSEARCH_KIBANA_VERSION)
	docker tag launcher.gcr.io/google/elasticsearch6:$(ELASTICSEARCH_KIBANA_VERSION) \
	    "$(REGISTRY)/elastic-gke-logging:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/kibana: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   | .build/elastic-gke-logging
	docker pull launcher.gcr.io/google/kibana6:$(ELASTICSEARCH_KIBANA_VERSION)
	docker tag launcher.gcr.io/google/kibana6:$(ELASTICSEARCH_KIBANA_VERSION) \
	    "$(REGISTRY)/elastic-gke-logging/kibana:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging/kibana:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/fluentd: .build/var/REGISTRY \
                                    .build/var/TAG \
                                    | .build/elastic-gke-logging
	docker pull launcher.gcr.io/google/fluentd1:$(FLUENTD_VERSION)
	docker tag launcher.gcr.io/google/fluentd1:$(FLUENTD_VERSION) \
	    "$(REGISTRY)/elastic-gke-logging/fluentd:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging/fluentd:$(TAG)"
	@touch "$@"


.build/elastic-gke-logging/ubuntu16_04: .build/var/REGISTRY \
                                        .build/var/TAG \
                                        | .build/elastic-gke-logging
	docker pull launcher.gcr.io/google/ubuntu16_04
	docker tag launcher.gcr.io/google/ubuntu16_04 \
	    "$(REGISTRY)/elastic-gke-logging/ubuntu16_04:$(TAG)"
	docker push "$(REGISTRY)/elastic-gke-logging/ubuntu16_04:$(TAG)"
	@touch "$@"
