include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile

TAG ?= 4.0.1
$(info ---- TAG = $(TAG))

#CONTAINER_REGISTRY ?= "gcr.io/cloud-marketplace-ops-test"
CONTAINER_REGISTRY ?= "gcr.io/orbitera-dev"
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/mongodb/deployer:$(TAG)
NAME ?= mongodb-1

ifdef IMAGE_MONGODB
  IMAGE_MONGODB_FIELD = , "IMAGE_MONGODB": "$(IMAGE_MONGODB)"
endif

ifdef REPLICAS
  IMAGE_MONGODB_INIT_FIELD = , "REPLICAS": "$(REPLICAS)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_MONGODB_FIELD) \
  $(IMAGE_MONGODB_INIT_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/mongodb/mongo-sidecar \
            .build/mongodb/deployer \
            .build/mongodb/mongodb


.build/mongodb: | .build
	mkdir -p "$@"


.build/mongodb/deployer: deployer/* \
                         manifest/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/mongodb
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/mongodb" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/mongodb/mongodb: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/mongodb
	docker pull $(CONTAINER_REGISTRY)/mongodb:$(TAG)
	docker tag $(CONTAINER_REGISTRY)/mongodb:$(TAG) "$(REGISTRY)/mongodb:$(TAG)"
	docker push "$(REGISTRY)/mongodb:$(TAG)"
	@touch "$@"


.build/mongodb/mongo-sidecar: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/mongodb
	docker pull $(CONTAINER_REGISTRY)/mongodb/mongodb-sidecar:$(TAG)
	docker tag $(CONTAINER_REGISTRY)/mongodb/mongodb-sidecar:$(TAG) "$(REGISTRY)/mongodb/mongodb-sidecar:$(TAG)"
	docker push "$(REGISTRY)/mongodb/mongodb-sidecar:$(TAG)"
	@touch "$@"
