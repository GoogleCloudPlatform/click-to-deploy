###########################################################
# Define convenience parameters (if not already defined). #
###########################################################

NAME ?= cassandra-1
TAG ?= latest

REGISTRY ?= gcr.io/$(shell gcloud config get-value project | tr ':' '/')

CASSANDRA_REGISTRY ?= $(REGISTRY)/cassandra
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

APP_DEPLOYER_IMAGE ?= $(CASSANDRA_REGISTRY)/deployer:latest
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)", \
  "IMAGE_CASSANDRA": "$(CASSANDRA_REGISTRY):$(TAG)" \
}
APP_TEST_PARAMETERS ?= {}

#######################################
# Define extensions for app.Makefile. #
#######################################

app/build:: .build/deployer .build/cassandra

.build/deployer: deployer/* manifest/* base/build/deployer/kubectl | gcloud/REGISTRY gcloud/TAG
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
.build/cassandra: | gcloud/REGISTRY gcloud/TAG
	gcloud docker -- pull launcher.gcr.io/google/cassandra3
	docker tag launcher.gcr.io/google/cassandra3 "$(CASSANDRA_REGISTRY):$(TAG)"
	gcloud docker -- push "$(CASSANDRA_REGISTRY):$(TAG)"
	@touch "$@"
