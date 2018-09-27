include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile

TAG ?= 4.0.1
$(info ---- TAG = $(TAG))

#temporarry 
CONTAINER_REGISTRY ?= gcr.io/cloud-marketplace-ops-test


SOURCE_REGISTRY_SOLUTION_NAME ?= mongodb4
DESTYNATION_REGISTRY_SOLUTION_NAME ?= mongodb4
NAME ?= mongodb-1
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(DESTYNATION_REGISTRY_SOLUTION_NAME)/deployer:$(TAG)

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
	    --build-arg REGISTRY="$(REGISTRY)/$(SOURCE_REGISTRY_SOLUTION_NAME)" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/mongodb/mongodb: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/mongodb
	docker pull $(CONTAINER_REGISTRY)/$(SOURCE_REGISTRY_SOLUTION_NAME):$(TAG)
	docker tag $(CONTAINER_REGISTRY)/$(SOURCE_REGISTRY_SOLUTION_NAME):$(TAG) "$(REGISTRY)/$(DESTYNATION_REGISTRY_SOLUTION_NAME):$(TAG)"
	docker push "$(REGISTRY)/$(DESTYNATION_REGISTRY_SOLUTION_NAME):$(TAG)"
	@touch "$@"


.build/mongodb/mongo-sidecar: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/mongodb
	docker pull $(CONTAINER_REGISTRY)/$(SOURCE_REGISTRY_SOLUTION_NAME)/mongodb-sidecar:$(TAG)
	docker tag $(CONTAINER_REGISTRY)/$(SOURCE_REGISTRY_SOLUTION_NAME)/mongodb-sidecar:$(TAG) "$(REGISTRY)/$(DESTYNATION_REGISTRY_SOLUTION_NAME)/mongodb-sidecar:$(TAG)"
	docker push "$(REGISTRY)/$(DESTYNATION_REGISTRY_SOLUTION_NAME)/mongodb-sidecar:$(TAG)"
	@touch "$@"
