###########################################################
# Define convenience parameters (if not already defined). #
###########################################################

NAME ?= elasticsearch-1
TAG ?= latest

REGISTRY ?= gcr.io/$(shell gcloud config get-value project | tr ':' '/')

ELASTICSEARCH_REGISTRY ?= $(REGISTRY)/elasticsearch
REGISTRY_FOR_DEPLOYER ?= $(REGISTRY)

########################################
# Include marketplace-tools Makefiles. #
########################################

include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/base_containers.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile

##############################################
# Define variables required by app.Makefile. #
##############################################

APP_DEPLOYER_IMAGE ?= $(ELASTICSEARCH_REGISTRY)/deployer:latest
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)", \
  "REPLICAS": "2" \
}
APP_TEST_PARAMETERS ?= {}

#######################################
# Define extensions for app.Makefile. #
#######################################

app/build:: .build/deployer .build/ubuntu16_04 .build/elasticsearch

.build/deployer: deployer/* manifest/* base/build/deployer/kubectl | gcloud/REGISTRY gcloud/TAG
	docker build \
	    --build-arg REGISTRY="$(REGISTRY_FOR_DEPLOYER)" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_REGISTRY="$(MARKETPLACE_REGISTRY)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

# Relocate public ubuntu16_04 image to $ELASTICSEARCH_REGISTRY.
.build/ubuntu16_04: | gcloud/REGISTRY gcloud/TAG
	docker pull launcher.gcr.io/google/ubuntu16_04
	docker tag launcher.gcr.io/google/ubuntu16_04 "$(ELASTICSEARCH_REGISTRY)/ubuntu16_04:$(TAG)"
	docker push "$(ELASTICSEARCH_REGISTRY)/ubuntu16_04:$(TAG)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/elasticsearch: | gcloud/REGISTRY gcloud/TAG
	docker pull launcher.gcr.io/google/elasticsearch5
	docker tag launcher.gcr.io/google/elasticsearch5 "$(ELASTICSEARCH_REGISTRY):$(TAG)"
	docker push "$(ELASTICSEARCH_REGISTRY):$(TAG)"
	@touch "$@"
