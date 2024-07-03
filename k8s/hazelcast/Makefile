include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := hazelcast
APP_ID ?= $(CHART_NAME)

TRACK ?= 5.3
TRACK_MC ?= 5.3
METRICS_EXPORTER_TAG ?= v0.5.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_HAZELCAST ?= $(SOURCE_REGISTRY)/hazelcast5:$(TRACK)
IMAGE_MANCENTER ?= $(SOURCE_REGISTRY)/hazelcast-mc5:$(TRACK_MC)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_HAZELCAST))

# List of images used in application
ADDITIONAL_IMAGES := mancenter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-mancenter := $(call get_sha256,$(IMAGE_MANCENTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
VERIFY_WAIT_TIMEOUT := 800
NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
