include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 6.3
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

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(REPLICAS_FIELD) \
  $(IMAGE_ELASTICSEARCH_FIELD) \
  $(IMAGE_INIT_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/elasticsearch/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/elasticsearch/elasticsearch \
            .build/elasticsearch/deployer \
            .build/elasticsearch/ubuntu16_04 \
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
	docker pull launcher.gcr.io/google/elasticsearch6:$(TAG)
	docker tag launcher.gcr.io/google/elasticsearch6:$(TAG) \
	    "$(REGISTRY)/elasticsearch:$(TAG)"
	docker push "$(REGISTRY)/elasticsearch:$(TAG)"
	@touch "$@"


.build/elasticsearch/ubuntu16_04: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/elasticsearch
	docker pull launcher.gcr.io/google/ubuntu16_04
	docker tag launcher.gcr.io/google/ubuntu16_04 \
	    "$(REGISTRY)/elasticsearch/ubuntu16_04:$(TAG)"
	docker push "$(REGISTRY)/elasticsearch/ubuntu16_04:$(TAG)"
	@touch "$@"


.build/elasticsearch/tester: .build/var/TESTER_IMAGE \
                             $(shell find apptest -type f) \
                             | .build/elasticsearch
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
