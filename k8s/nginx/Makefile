include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := nginx
APP_ID ?= $(CHART_NAME)

TRACK ?= 1.15

METRICS_EXPORTER_TAG ?= v0.9.0

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_NGINX ?= $(SOURCE_REGISTRY)/nginx1:$(TRACK)
IMAGE_DEBIAN9 ?= $(SOURCE_REGISTRY)/debian9:latest
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_NGINX))

# List of images used in application
ADDITIONAL_IMAGES := debian9 prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-debian9 :=  $(call get_sha256,$(IMAGE_DEBIAN9))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

ifdef CURATED_METRICS_EXPORTER_ENABLED
  CURATED_METRICS_EXPORTER_ENABLED_FIELD = , "metrics.curatedExporter.enabled": $(CURATED_METRICS_EXPORTER_ENABLED)
endif

ifdef IMAGE_NGINX_INIT
  IMAGE_NGINX_INIT_FIELD = , "nginx.initImage": "$(IMAGE_NGINX_INIT)"
endif

ifdef PUBLIC_IP_AVAILABLE
  PUBLIC_IP_AVAILABLE_FIELD = , "publicIp.available": $(PUBLIC_IP_AVAILABLE)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_NGINX_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(CURATED_METRICS_EXPORTER_ENABLED_FIELD) \
  $(PUBLIC_IP_AVAILABLE_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
