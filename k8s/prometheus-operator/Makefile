include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := prometheus-operator
APP_ID ?= $(CHART_NAME)

TRACK ?= 0.34

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_MAIN ?= $(SOURCE_REGISTRY)/prometheus-operator0:$(TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_MAIN))

# List of images used in application

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
# Should be dynamically to use $(MARKETPLACE_TOOLS_TAG)

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
