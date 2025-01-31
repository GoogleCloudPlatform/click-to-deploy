include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := prometheus
APP_ID ?= $(CHART_NAME)

TRACK ?= 2.54
SERVICE_NAME := services/057070e7-b352-4b46-bc03-fc8f141fce9a.cloudpartnerservices.goog
TRACK_ALERTMANAGER ?= 0.27
TRACK_KUBESTATEMETRICS ?= 2.13
TRACK_NODEEXPORTER ?= 1.8

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_PROMETHEUS ?= $(SOURCE_REGISTRY)/prometheus2:$(TRACK)
IMAGE_ALERTMANAGER ?= $(SOURCE_REGISTRY)/prometheus-alertmanager0:$(TRACK_ALERTMANAGER)
IMAGE_NODEEXPORTER ?= $(SOURCE_REGISTRY)/prometheus-nodeexporter1:$(TRACK_NODEEXPORTER)
IMAGE_KUBESTATEMETRICS ?= $(SOURCE_REGISTRY)/kube-state-metrics2:$(TRACK_KUBESTATEMETRICS)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_PROMETHEUS))

# List of images used in application
ADDITIONAL_IMAGES := alertmanager nodeexporter kubestatemetrics

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-alertmanager := $(call get_sha256,$(IMAGE_ALERTMANAGER))
image-nodeexporter := $(call get_sha256,$(IMAGE_NODEEXPORTER))
image-kubestatemetrics := $(call get_sha256,$(IMAGE_KUBESTATEMETRICS))

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
