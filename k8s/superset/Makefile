include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := superset
APP_ID ?= $(CHART_NAME)

TRACK ?= 4.0
SERVICE_NAME := services/e6580ff4-fda7-4750-b7a4-aeec14eecc6a.cloudpartnerservices.goog

METRICS_EXPORTER_TAG ?= v0.11.1-gke.1
REDIS_EXPORTER_TAG ?= 1.63
POSTGRESQL_EXPORTER_TAG ?= latest
POSTGRESQL_TAG ?= 16.4
REDIS_TAG ?= 7.2
STATSD_EXPORTER_TAG ?= 0.27

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_SUPERSET ?= $(SOURCE_REGISTRY)/superset4:$(TRACK)
IMAGE_STATSD_EXPORTER ?= $(SOURCE_REGISTRY)/statsd-exporter0:$(STATSD_EXPORTER_TAG)
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql16:$(POSTGRESQL_TAG)
IMAGE_POSTGRESQL_EXPORTER ?= $(SOURCE_REGISTRY)/postgresql-exporter0:$(POSTGRESQL_EXPORTER_TAG)
IMAGE_REDIS ?= $(SOURCE_REGISTRY)/redis7:$(REDIS_TAG)
IMAGE_REDIS_EXPORTER ?= $(SOURCE_REGISTRY)/redis-exporter1:$(REDIS_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_SUPERSET))

# List of images used in application
ADDITIONAL_IMAGES := postgresql postgresql-exporter redis redis-exporter prometheus-to-sd statsd-exporter

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-statsd-exporter := $(call get_sha256,$(IMAGE_STATSD_EXPORTER))
image-postgresql := $(call get_sha256,$(IMAGE_POSTGRESQL))
image-postgresql-exporter := $(call get_sha256,$(IMAGE_POSTGRESQL_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))
image-redis := $(call get_sha256,$(IMAGE_REDIS))
image-redis-exporter := $(call get_sha256,$(IMAGE_REDIS_EXPORTER))
image-postgresql-exporter := $(call get_sha256,$(IMAGE_POSTGRESQL_EXPORTER))


C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef PUBLIC_SERVICE_AND_INGRESS_ENABLED
  PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD = , "enablePublicServiceAndIngress": $(PUBLIC_SERVICE_AND_INGRESS_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
