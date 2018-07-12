include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= 3.11
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/cassandra/deployer:$(TAG)
NAME ?= cassandra-1

ifdef REPLICAS
  REPLICAS_FIELD = , "REPLICAS": "$(REPLICAS)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)"\
  $(REPLICAS_FIELD) \
}

APP_TEST_PARAMETERS ?= {}


app/build:: .build/cassandra/cassandra \
            .build/cassandra/deployer


.build/cassandra: | .build
	mkdir -p "$@"


.build/cassandra/deployer: deployer/* \
                           manifest/* \
                           .build/marketplace/deployer/envsubst \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/cassandra
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/cassandra" \
	    --build-arg TAG="$(TAG)" \
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
