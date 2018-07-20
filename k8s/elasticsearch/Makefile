include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= 6.3
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/elasticsearch/deployer:$(TAG)
NAME ?= elasticsearch-1

ifdef REPLICAS
  REPLICAS_FIELD = , "REPLICAS": "$(REPLICAS)"
endif

ifdef IMAGE_ELASTICSEARCH
  IMAGE_ELASTICSEARCH_FIELD = , "IMAGE_ELASTICSEARCH": "$(IMAGE_ELASTICSEARCH)"
endif

ifdef IMAGE_INIT
  IMAGE_INIT_FIELD = , "IMAGE_INIT": "$(IMAGE_INIT)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(REPLICAS_FIELD) \
  $(IMAGE_ELASTICSEARCH_FIELD) \
  $(IMAGE_INIT_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/elasticsearch/elasticsearch \
            .build/elasticsearch/deployer \
            .build/elasticsearch/ubuntu16_04


.build/elasticsearch: | .build
	mkdir -p "$@"


.build/elasticsearch/deployer: deployer/* \
                               manifest/* \
                               schema.yaml \
                               .build/var/APP_DEPLOYER_IMAGE \
                               .build/var/REGISTRY \
                               .build/var/TAG \
                               | .build/elasticsearch
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/elasticsearch" \
	    --build-arg TAG="$(TAG)" \
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
