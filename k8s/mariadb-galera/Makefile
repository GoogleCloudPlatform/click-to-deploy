include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := mariadb-galera
APP_ID ?= $(CHART_NAME)

VERIFY_WAIT_TIMEOUT = 1800

TRACK ?= 11.5
SERVICE_NAME := services/8afcaf9c-1b2d-47c1-93f0-588a78dccca9.cloudpartnerservices.goog
METRICS_EXPORTER_TAG ?= v0.5.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_MARIADB ?= $(SOURCE_REGISTRY)/mariadb11:$(TRACK)
IMAGE_MYSQLD_EXPORTER ?= $(SOURCE_REGISTRY)/mysql8:exporter
IMAGE_PROMETHEUS_TO_SD ?= eu.gcr.io/k8s-artifacts-prod/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_MARIADB))

# List of images used in application
ADDITIONAL_IMAGES := mysqld-exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-mysqld-exporter := $(call get_sha256,$(IMAGE_MYSQLD_EXPORTER))
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
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}


# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
