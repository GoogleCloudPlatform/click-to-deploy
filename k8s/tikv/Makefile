include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := tikv
APP_ID ?= $(CHART_NAME)

SOURCE_REGISTRY ?= gcr.io/ccm-ops-test-adhoc

TRACK ?= 5.3

IMAGE_TIKV ?= gcr.io/ccm-ops-test-adhoc/tikv5:$(TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_TIKV))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# app_v2.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

# Build tester image
app/build:: .build/$(CHART_NAME)/tester
