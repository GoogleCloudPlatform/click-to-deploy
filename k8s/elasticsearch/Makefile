include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_NAME ?= elasticsearch
APP_ID ?= $(APP_NAME)-managed-updates

SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 6.3

# Images have tags and var_tag:
METRICS_EXPORTER_TAG ?= v0.5.1

# List of images used in application
TARGET_IMAGES := ubuntu16_04 prometheus-to-sd

# Image variable names should correspond with TARGET_IMAGES list
image-$(APP_NAME) := $(call get_sha256,$(SOURCE_REGISTRY)/elasticsearch6:$(TRACK))
image-ubuntu16_04 :=  $(call get_sha256,$(SOURCE_REGISTRY)/ubuntu1604:latest)
image-prometheus-to-sd :=  $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(APP_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1

ifdef REPLICAS
  REPLICAS_FIELD = , "elasticsearch.replicas": "$(REPLICAS)"
endif

ifdef IMAGE_INIT
  IMAGE_INIT_FIELD = , "elasticsearch.initImage": "$(IMAGE_INIT)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(REPLICAS_FIELD) \
  $(IMAGE_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

