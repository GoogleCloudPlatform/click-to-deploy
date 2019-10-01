include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := mariadb-galera
APP_ID ?= $(CHART_NAME)

SOURCE_REGISTRY ?= marketplace.gcr.io/google

VERIFY_WAIT_TIMEOUT = 1800

TRACK ?= 10.3
METRICS_EXPORTER_TAG ?= v0.5.1
PEER_FINDER_TAG ?= latest

# List of images used in application
ADDITIONAL_IMAGES := mysqld-exporter prometheus-to-sd peer-finder

# Main image
image-$(CHART_NAME) ?= $(call get_sha256,$(SOURCE_REGISTRY)/mariadb10:$(TRACK))

# Image variable names should correspond with ADDITIONAL_IMAGES list
image-mysqld-exporter ?= $(call get_sha256,$(SOURCE_REGISTRY)/mysql5:exporter)
image-peer-finder ?= $(call get_sha256,$(SOURCE_REGISTRY)/peer-finder0:$(PEER_FINDER_TAG))
image-prometheus-to-sd ?= $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

# TODO(kalinichenka): Replace with C2D_RELEASE variable after container is updated.
# C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))
C2D_CONTAINER_RELEASE ?= 10.3.18

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "prometheusToSd.enabled": $(METRICS_EXPORTER_ENABLED)
endif

NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile
