include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := tikv
APP_ID ?= $(CHART_NAME)
WAIT_FOR_READY_TIMEOUT := 600
VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 6.5
METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

IMAGE_TIKV ?= $(SOURCE_REGISTRY)/tikv6:$(TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_TIKV))

# Prometheus-to-SD
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# List of images used in application
ADDITIONAL_IMAGES := prometheus-to-sd

image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))
C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# app_v2.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

# Build tester image
app/build:: .build/$(CHART_NAME)/tester
