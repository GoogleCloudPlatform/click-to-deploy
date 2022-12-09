include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := dragonfly
APP_ID ?= $(CHART_NAME)
WAIT_FOR_READY_TIMEOUT := 900

TRACK ?= 2.0
MYSQL_TAG ?= 5.7
REDIS_TAG ?= 6.2
MYSQL_EXPORTER_TAG ?= exporter
REDIS_EXPORTER_TAG ?= latest
METRICS_EXPORTER_TAG ?= v0.5.1


SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_DRAGONFLY_MANAGER ?= $(SOURCE_REGISTRY)/dragonfly-manager2:$(TRACK)
IMAGE_DRAGONFLY_SCHEDULER ?= $(SOURCE_REGISTRY)/dragonfly-scheduler2:$(TRACK)
IMAGE_DRAGONFLY_SEEDPEER ?= $(SOURCE_REGISTRY)/dragonfly-seed-peer2:$(TRACK)
IMAGE_DRAGONFLY_DFGET ?= $(SOURCE_REGISTRY)/dragonfly-dfget2:$(TRACK)
IMAGE_MYSQL ?= $(SOURCE_REGISTRY)/mysql5:$(MYSQL_TAG)
IMAGE_REDIS ?= $(SOURCE_REGISTRY)/redis6:$(REDIS_TAG)
IMAGE_MYSQL_EXPORTER ?= $(SOURCE_REGISTRY)/mysql5:$(MYSQL_EXPORTER_TAG)
IMAGE_REDIS_EXPORTER ?= $(SOURCE_REGISTRY)/redis-exporter1:$(REDIS_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_DRAGONFLY_MANAGER))

# List of images used in application
ADDITIONAL_IMAGES := mysql mysql-exporter redis redis-exporter prometheus-to-sd scheduler seedpeer dfget

# Additional images variable names should correspond with ADDITIONAL_IMAGES list

image-scheduler := $(call get_sha256,$(IMAGE_DRAGONFLY_SCHEDULER))
image-seedpeer := $(call get_sha256,$(IMAGE_DRAGONFLY_SEEDPEER))
image-dfget := $(call get_sha256,$(IMAGE_DRAGONFLY_DFGET))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))
image-mysql := $(call get_sha256,$(IMAGE_MYSQL))
image-mysql-exporter := $(call get_sha256,$(IMAGE_MYSQL_EXPORTER))
image-redis := $(call get_sha256,$(IMAGE_REDIS))
image-redis-exporter := $(call get_sha256,$(IMAGE_REDIS_EXPORTER))
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
