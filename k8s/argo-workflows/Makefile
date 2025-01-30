include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := argo-workflows
APP_ID ?= $(CHART_NAME)

TRACK ?= 3.5
SERVICE_NAME := services/f6f7625a-8d55-4b9d-a394-cdd8e6b47b44.cloudpartnerservices.goog

EXPORTER_TAG ?= exporter
POSTGRESQL_EXPORTER_TAG ?= 0.15
METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

VERIFY_WAIT_TIMEOUT = 600

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_ARGOWORKFLOWS ?= $(SOURCE_REGISTRY)/argo-workflows3:$(TRACK)
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql16
IMAGE_PG_EXPORTER ?= $(SOURCE_REGISTRY)/postgresql-exporter0:$(POSTGRESQL_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_ARGOWORKFLOWS))

# List of images used in application
ADDITIONAL_IMAGES := postgresql postgresql-exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-postgresql := $(call get_sha256,$(IMAGE_POSTGRESQL))
image-postgresql-exporter := $(call get_sha256,$(IMAGE_PG_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
