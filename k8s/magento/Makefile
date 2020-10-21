include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := magento
APP_ID ?= $(CHART_NAME)

TRACK ?= 2.4
MYSQL_TAG ?= 5.7
REDIS_TAG ?= 5.0
ELASTICSEARCH_TAG ?= 7.8
EXPORTER_TAG ?= exporter
METRICS_EXPORTER_TAG ?= v0.5.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google

IMAGE_MAGENTO ?= $(SOURCE_REGISTRY)/magento2-php7-fpm:$(TRACK)
IMAGE_NGINX_EXPORTER ?= $(SOURCE_REGISTRY)/nginx1:$(EXPORTER_TAG)
IMAGE_MYSQL ?= $(SOURCE_REGISTRY)/mysql5:$(MYSQL_TAG)
IMAGE_REDIS ?= $(SOURCE_REGISTRY)/redis5:$(REDIS_TAG)
IMAGE_MYSQL_EXPORTER ?= $(SOURCE_REGISTRY)/mysql5:$(EXPORTER_TAG)
IMAGE_REDIS_EXPORTER ?= $(SOURCE_REGISTRY)/redis5:$(EXPORTER_TAG)
IMAGE_ELASTICSEARCH ?= $(SOURCE_REGISTRY)/elasticsearch7:$(ELASTICSEARCH_TAG)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_MAGENTO))

# List of images used in application
ADDITIONAL_IMAGES := nginx-exporter mysql mysql-exporter redis redis-exporter elasticsearch prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-nginx-exporter := $(call get_sha256,$(IMAGE_NGINX_EXPORTER))
image-mysql := $(call get_sha256,$(IMAGE_MYSQL))
image-mysql-exporter := $(call get_sha256,$(IMAGE_MYSQL_EXPORTER))
image-redis := $(call get_sha256,$(IMAGE_REDIS))
image-redis-exporter := $(call get_sha256,$(IMAGE_REDIS_EXPORTER))
image-elasticsearch := $(call get_sha256,$(IMAGE_ELASTICSEARCH))
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
