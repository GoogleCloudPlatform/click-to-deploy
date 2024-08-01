include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := conjur
APP_ID ?= $(CHART_NAME)
WAIT_FOR_READY_TIMEOUT := 600

TRACK ?= 1.19
# Track for components
POSTGRESQL_TRACK ?= 13.8

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google

IMAGE_CONJUR ?= $(SOURCE_REGISTRY)/conjur1:$(TRACK)

# POSTGRESQL
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql13:$(POSTGRESQL_TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_CONJUR))

# List of images used in application
ADDITIONAL_IMAGES := postgresql

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-postgresql := $(call get_sha256,$(IMAGE_POSTGRESQL))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef PUBLIC_SERVICE_AND_INGRESS_ENABLED
  PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD = , "enablePublicServiceAndIngress": $(PUBLIC_SERVICE_AND_INGRESS_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
