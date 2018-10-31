include ../app.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 3.11
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/cassandra/deployer:$(TAG)
NAME ?= cassandra-1

ifdef IMAGE_CASSANDRA
  IMAGE_CASSANDRA_FIELD = , "IMAGE_CASSANDRA": "$(IMAGE_CASSANDRA)"
endif

ifdef REPLICAS
  REPLICAS_FIELD = , "REPLICAS": "$(REPLICAS)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_CASSANDRA_FIELD) \
  $(REPLICAS_FIELD) \
}

APP_TEST_PARAMETERS ?= {}


app/build:: .build/cassandra/cassandra \
            .build/cassandra/deployer


.build/cassandra: | .build
	mkdir -p "$@"


.build/cassandra/deployer: deployer/* \
                           manifest/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
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
	docker pull launcher.gcr.io/google/cassandra3:$(TAG)
	docker tag launcher.gcr.io/google/cassandra3:$(TAG) \
	    "$(REGISTRY)/cassandra:$(TAG)"
	docker push "$(REGISTRY)/cassandra:$(TAG)"
	@touch "$@"
