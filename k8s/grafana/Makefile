include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := grafana
APP_ID ?= $(CHART_NAME)

TRACK ?= 7.4

METRICS_EXPORTER_TAG ?= v0.5.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_GRAFANA ?= $(SOURCE_REGISTRY)/grafana7:$(TRACK)
IMAGE_DEBIAN9 ?= $(SOURCE_REGISTRY)/debian9:latest
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_GRAFANA))

# List of images used in application
ADDITIONAL_IMAGES := debian9 prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-debian9 := $(call get_sha256,$(IMAGE_DEBIAN9))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef IMAGE_GRAFANA_INIT
  IMAGE_GRAFANA_INIT_FIELD = , "grafana.initImage": "$(IMAGE_GRAFANA_INIT)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_GRAFANA_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
