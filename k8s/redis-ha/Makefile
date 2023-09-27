include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

VERIFY_WAIT_TIMEOUT = 1200

CHART_NAME := redis-ha
APP_ID ?= $(CHART_NAME)

TRACK ?= 7.2

REDIS_EXPORTER_TAG ?= 1.54
METRICS_EXPORTER_TAG ?= v0.5.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_MAIN ?= $(SOURCE_REGISTRY)/redis7:$(TRACK)
IMAGE_HAPROXY = $(SOURCE_REGISTRY)/haproxy2:2
IMAGE_EXPORTER = $(SOURCE_REGISTRY)/redis-exporter1:$(REDIS_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_MAIN))

# List of images used in application
ADDITIONAL_IMAGES := redis-exporter haproxy prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
# Should be dynamically to use $(MARKETPLACE_TOOLS_TAG)
image-redis-exporter := $(call get_sha256,$(IMAGE_EXPORTER))
image-haproxy := $(call get_sha256,$(IMAGE_HAPROXY))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE ?= $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))
$(info ---- SOURCE_REGISTRY = $(SOURCE_REGISTRY))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# app_v2.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

# Build tester image
app/build:: .build/$(CHART_NAME)/tester
