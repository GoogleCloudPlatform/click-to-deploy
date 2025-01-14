include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := airflow
APP_ID ?= $(CHART_NAME)
WAIT_FOR_READY_TIMEOUT := 600

TRACK ?= 2.10
SERVICE_NAME := services/a04a14b8-4fd4-469b-93c0-f540ac6eca56.cloudpartnerservices.goog

# Track for components
POSTGRESQL_TRACK ?= latest
NFS_TRACK ?= 1.3
METRICS_EXPORTER_TAG ?= v0.5.1

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google

IMAGE_AIRFLOW ?= $(SOURCE_REGISTRY)/airflow2:$(TRACK)

# POSTGRESQL
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql13:$(POSTGRESQL_TRACK)

# NFS
IMAGE_NFS ?= $(SOURCE_REGISTRY)/nfs-server1:$(NFS_TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_AIRFLOW))

# Prometheus-to-SD
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# List of images used in application
ADDITIONAL_IMAGES := postgresql nfs prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-postgresql := $(call get_sha256,$(IMAGE_POSTGRESQL))
image-nfs := $(call get_sha256,$(IMAGE_NFS))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef PUBLIC_SERVICE_AND_INGRESS_ENABLED
  PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD = , "enablePublicServiceAndIngress": $(PUBLIC_SERVICE_AND_INGRESS_ENABLED)
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
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
