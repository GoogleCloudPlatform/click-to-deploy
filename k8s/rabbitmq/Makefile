###########################################################
# Define convenience parameters (if not already defined). #
###########################################################

NAME = rabbitmq-1
TAG ?= latest

REGISTRY ?= gcr.io/$(shell gcloud config get-value project | tr ':' '/')
RABBITMQ_REGISTRY ?= $(REGISTRY)/rabbitmq
REGISTRY_FOR_DEPLOYER ?= $(RABBITMQ_REGISTRY)

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

APP_DEPLOYER_IMAGE ?= $(RABBITMQ_REGISTRY)/deployer:latest
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)", \
  "IMAGE_RABBITMQ": "$(RABBITMQ_REGISTRY)" \
}
APP_TEST_PARAMETERS ?= {}

#######################################
# Define extensions for app.Makefile. #
#######################################


app/build:: .build/deployer .build/rabbitmq

.build/deployer: deployer/* manifest/* base/build/deployer/kubectl | gcloud/REGISTRY
	docker build \
	    --build-arg REGISTRY="$(REGISTRY_FOR_DEPLOYER)" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_REGISTRY="$(MARKETPLACE_REGISTRY)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	gcloud docker -- push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/rabbitmq: | gcloud/REGISTRY
	gcloud docker -- pull launcher.gcr.io/google/rabbitmq3
	docker tag launcher.gcr.io/google/rabbitmq3 "$(RABBITMQ_REGISTRY):$(TAG)"
	gcloud docker -- push "$(RABBITMQ_REGISTRY):$(TAG)"
	@touch "$@"
