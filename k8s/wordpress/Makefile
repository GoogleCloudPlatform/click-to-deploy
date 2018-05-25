###########################################################
# Define convenience parameters (if not already defined). #
###########################################################

NAME ?= wordpress-1
TAG ?= latest

REGISTRY ?= gcr.io/$(shell gcloud config get-value project | tr ':' '/')

WORDPRESS_REGISTRY ?= $(REGISTRY)/wordpress
REGISTRY_FOR_DEPLOYER ?= $(REGISTRY)

########################################
# Include marketplace-tools Makefiles. #
########################################

include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile

##############################################
# Define variables required by app.Makefile. #
##############################################

APP_DEPLOYER_IMAGE ?= $(WORDPRESS_REGISTRY)/deployer:latest
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)", \
  "IMAGE_WORDPRESS": "$(WORDPRESS_REGISTRY):$(TAG)", \
  "IMAGE_MYSQL": "$(WORDPRESS_REGISTRY)/mysql:$(TAG)" \
}
APP_TEST_PARAMETERS ?= {}

#######################################
# Define extensions for app.Makefile. #
#######################################

app/build:: .build/deployer .build/wordpress .build/mysql

.build/deployer: deployer/* manifest/* \
                 .build/marketplace/deployer/envsubst \
                 .build/var/APP_DEPLOYER_IMAGE \
                 .build/var/REGISTRY \
                 .build/var/REGISTRY_FOR_DEPLOYER \
                 .build/var/TAG
	docker build \
	    --build-arg REGISTRY="$(REGISTRY_FOR_DEPLOYER)" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg REGISTRY="$(REGISTRY)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/wordpress: .build/var/REGISTRY \
                  .build/var/TAG \
                  .build/var/WORDPRESS_REGISTRY
	docker pull launcher.gcr.io/google/wordpress4-php5-apache
	docker tag launcher.gcr.io/google/wordpress4-php5-apache "$(WORDPRESS_REGISTRY):$(TAG)"
	docker push "$(WORDPRESS_REGISTRY):$(TAG)"
	@touch "$@"

# Relocate public mysql image to $REGISTRY.
.build/mysql: .build/var/REGISTRY \
              .build/var/TAG \
              .build/var/WORDPRESS_REGISTRY
	docker pull launcher.gcr.io/google/mysql5
	docker tag launcher.gcr.io/google/mysql5 "$(WORDPRESS_REGISTRY)/mysql:$(TAG)"
	docker push "$(WORDPRESS_REGISTRY)/mysql:$(TAG)"
	@touch "$@"
