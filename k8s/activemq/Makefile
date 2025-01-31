include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := activemq
APP_ID ?= $(CHART_NAME)

TRACK ?= 6.1
SERVICE_NAME ?= services/450acd45-a325-47bc-a603-0d79951b9800.cloudpartnerservices.goog

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_ACTIVEMQ ?= $(SOURCE_REGISTRY)/activemq6:$(TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_ACTIVEMQ))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
