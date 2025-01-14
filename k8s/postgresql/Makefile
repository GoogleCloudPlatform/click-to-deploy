include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := postgresql
APP_ID ?= $(CHART_NAME)

TRACK ?= 16.4
SERVICE_NAME := services/9fef4505-b5b0-4051-9078-bb00a639b18a.cloudpartnerservices.goog

POSTGRESQL_TAG ?= $(TRACK)
POSTGRESQL_EXPORTER_TAG ?= 0.15
METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql16:$(POSTGRESQL_TAG)
IMAGE_EXPORTER ?= $(SOURCE_REGISTRY)/postgresql-exporter0:$(POSTGRESQL_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_POSTGRESQL))

# List of images used in application
ADDITIONAL_IMAGES := exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-exporter := $(call get_sha256,$(IMAGE_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

ifdef EXPOSE_PUBLIC_SERVICE
  EXPOSE_PUBLIC_SERVICE_FIELD = , "postgresql.exposePublicService": "$(EXPOSE_PUBLIC_SERVICE)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(EXPOSE_PUBLIC_SERVICE_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
