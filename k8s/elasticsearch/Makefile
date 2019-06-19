include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= elasticsearch-managed-updates

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/elasticsearch/VERSION` target to fill the RELEASE variable.
ELASTICSEARCH_TAG ?= sha256:b040840b3dde56c44396710f7e52d00eeec56db4b0d9476369eceb20f9575672
METRICS_EXPORTER_TAG ?= v0.5.1

TIMESTAMP := $(shell date +%s)
TRACK ?= 6.3
RELEASE ?= 6.3.2-build.$(TIMESTAMP)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef REPLICAS
  REPLICAS_FIELD = , "elasticsearch.replicas": "$(REPLICAS)"
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
  $(IMAGE_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile


app/build:: .build/elasticsearch/elasticsearch \
            .build/elasticsearch/deployer \
            .build/elasticsearch/ubuntu16_04 \
            .build/elasticsearch/prometheus-to-sd \
            .build/elasticsearch/tester \
            .build/elasticsearch/VERSION


.build/elasticsearch: | .build
	mkdir -p "$@"


.PHONY: .build/elasticsearch/VERSION
.build/elasticsearch/VERSION:
	docker run --rm --entrypoint=printenv marketplace.gcr.io/google/elasticsearch6@$(ELASTICSEARCH_TAG) ELASTICSEARCH_VERSION


.build/elasticsearch/deployer: deployer/* \
                               chart/elasticsearch/* \
                               chart/elasticsearch/templates/* \
                               schema.yaml \
                               .build/var/APP_DEPLOYER_IMAGE \
                               .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                               .build/var/MARKETPLACE_TOOLS_TAG \
                               .build/var/REGISTRY \
                               .build/var/TRACK \
                               .build/var/RELEASE \
                               | .build/elasticsearch
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


.build/elasticsearch/elasticsearch: .build/var/REGISTRY \
                                    .build/var/TRACK \
                                    .build/var/RELEASE \
                                    | .build/elasticsearch
	docker pull marketplace.gcr.io/google/elasticsearch6@$(ELASTICSEARCH_TAG)
	docker tag marketplace.gcr.io/google/elasticsearch6@$(ELASTICSEARCH_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/elasticsearch/ubuntu16_04: .build/var/REGISTRY \
                                  .build/var/TRACK \
                                  .build/var/RELEASE \
                                  | .build/elasticsearch
	docker pull marketplace.gcr.io/google/ubuntu16_04
	docker tag marketplace.gcr.io/google/ubuntu16_04 \
	    "$(REGISTRY)/$(APP_ID)/ubuntu16_04:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/ubuntu16_04:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/ubuntu16_04:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/ubuntu16_04:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/ubuntu16_04:$(RELEASE)"
	@touch "$@"


.build/elasticsearch/prometheus-to-sd: .build/var/REGISTRY \
                                       .build/var/TRACK \
                                       .build/var/RELEASE \
                                       | .build/elasticsearch
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/elasticsearch/tester: .build/var/TESTER_IMAGE \
                             $(shell find apptest -type f) \
                             | .build/elasticsearch
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
