include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME ?= consul
APP_ID ?= $(CHART_NAME)

SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 1.4
CONSUL_EXPORTER_TAG ?= exporter
METRICS_EXPORTER_TAG ?= v0.5.1

# List of images used in application
ADDITIONAL_IMAGES := consul-exporter prometheus-to-sd

# Main image
image-$(CHART_NAME) ?= $(call get_sha256,$(SOURCE_REGISTRY)/consul1:$(TRACK))

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-consul-exporter ?=  $(call get_sha256,$(SOURCE_REGISTRY)/consul1:$(CONSUL_EXPORTER_TAG))
image-prometheus-to-sd ?=  $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile
