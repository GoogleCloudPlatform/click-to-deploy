include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_ID ?= consul

SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 1.4
METRICS_EXPORTER_TAG ?= v0.5.1

# List of images used in application
TARGETS := consul-exporter prometheus-to-sd

# Image names should correspond with TARGET_IMAGES list
image-$(APP_ID) ?= $(call get_sha256,$(SOURCE_REGISTRY)/consul1:$(TRACK))
image-consul-exporter ?= $(call get_sha256,$(SOURCE_REGISTRY)/consul1:exporter)
image-prometheus-to-sd ?= $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE ?= $(call get_var_from_container,$(image-$(APP_ID)),CONSUL_VERSION)

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))
$(info ---- SOURCE_REGISTRY = $(SOURCE_REGISTRY))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}


# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2_1.Makefile
