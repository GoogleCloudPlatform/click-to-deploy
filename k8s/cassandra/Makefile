include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 3.11
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/cassandra/deployer:$(TAG)
NAME ?= cassandra-1

ifdef IMAGE_CASSANDRA
  IMAGE_CASSANDRA_FIELD = , "cassandra.image": "$(IMAGE_CASSANDRA)"
endif

ifdef REPLICAS
  REPLICAS_FIELD = , "cassandra.replicas": "$(REPLICAS)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_CASSANDRA_FIELD) \
  $(REPLICAS_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/cassandra/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/cassandra/cassandra \
            .build/cassandra/deployer \
            .build/cassandra/tester


.build/cassandra: | .build
	mkdir -p "$@"


.build/cassandra/deployer: deployer/* \
                           chart/cassandra/* \
                           chart/cassandra/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/cassandra
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/cassandra" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/cassandra/cassandra: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/cassandra
	docker pull marketplace.gcr.io/google/cassandra3:$(TAG)
	docker tag marketplace.gcr.io/google/cassandra3:$(TAG) \
	    "$(REGISTRY)/cassandra:$(TAG)"
	docker push "$(REGISTRY)/cassandra:$(TAG)"
	@touch "$@"

.build/cassandra/tester:   .build/var/TESTER_IMAGE \
                           $(shell find apptest -type f) \
                           | .build/cassandra
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
