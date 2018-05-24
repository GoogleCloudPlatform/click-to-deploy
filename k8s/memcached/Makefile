###########################################################
# Define convenience parameters (if not already defined). #
###########################################################

NAME ?= memcached-1
TAG ?= latest

REGISTRY ?= gcr.io/$(shell gcloud config get-value project | tr ':' '/')

MEMCACHED_REGISTRY ?= $(REGISTRY)/memcached
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

APP_DEPLOYER_IMAGE ?= $(MEMCACHED_REGISTRY)/deployer:latest
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)", \
  "IMAGE_MEMCACHED": "$(MEMCACHED_REGISTRY):$(TAG)" \
}
APP_TEST_PARAMETERS ?= {}

#######################################
# Define extensions for app.Makefile. #
#######################################

app/build:: .build/deployer .build/memcached

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
.build/memcached: | gcloud/REGISTRY
	gcloud docker -- pull launcher.gcr.io/google/memcached1
	docker tag launcher.gcr.io/google/memcached1 "$(MEMCACHED_REGISTRY):$(TAG)"
	gcloud docker -- push "$(MEMCACHED_REGISTRY):$(TAG)"
	@touch "$@"
