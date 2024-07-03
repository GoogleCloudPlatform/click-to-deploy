include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := mediawiki
APP_ID ?= $(CHART_NAME)

TRACK ?= 1.40

MARIADB_TAG ?= 10.11
EXPORTER_TAG ?= exporter
APACHE_EXPORTER_TAG ?= 0.13
METRICS_EXPORTER_TAG ?= v0.5.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google

IMAGE_MEDIAWIKI ?= $(SOURCE_REGISTRY)/mediawiki1-php7-apache:$(TRACK)
IMAGE_APACHE_EXPORTER ?= $(SOURCE_REGISTRY)/apache-exporter0:$(APACHE_EXPORTER_TAG)
IMAGE_MYSQL ?= $(SOURCE_REGISTRY)/mariadb10:$(MARIADB_TAG)
IMAGE_MYSQL_EXPORTER ?= $(SOURCE_REGISTRY)/mysql8:$(EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_MEDIAWIKI))

# List of images used in application
ADDITIONAL_IMAGES := apache-exporter mysql mysql-exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-apache-exporter := $(call get_sha256,$(IMAGE_APACHE_EXPORTER))
image-mysql := $(call get_sha256,$(IMAGE_MYSQL))
image-mysql-exporter := $(call get_sha256,$(IMAGE_MYSQL_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
VERIFY_WAIT_TIMEOUT := 400

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
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

# Build tester image
app/build:: .build/$(CHART_NAME)/tester
