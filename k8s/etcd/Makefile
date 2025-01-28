include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := etcd
APP_ID ?= $(CHART_NAME)

TRACK ?= 3.5
SERVICE_NAME := services/8179d7ea-7a6d-4054-b2bc-27caef69db5a.cloudpartnerservices.goog

METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_ETCD ?= $(SOURCE_REGISTRY)/etcd3:$(TRACK)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_ETCD))

# List of images used in application
ADDITIONAL_IMAGES := prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

ifdef REPLICAS
  REPLICAS_FIELD = , "replicas": $(REPLICAS)
endif


APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(REPLICAS_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
