include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := rabbitmq
APP_ID ?= $(CHART_NAME)

TRACK ?= 3.13
SERVICE_NAME := services/95b23cea-d381-42ec-8459-27ede8f4fd5a.cloudpartnerservices.goog

METRICS_EXPORTER_TAG ?= v0.9.0

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_RABBITMQ ?= $(SOURCE_REGISTRY)/rabbitmq3:$(TRACK)
IMAGE_DEBIAN ?= $(SOURCE_REGISTRY)/debian12:latest
IMAGE_PROMETHEUS_TO_SD ?= eu.gcr.io/k8s-artifacts-prod/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_RABBITMQ))

# List of images used in application
ADDITIONAL_IMAGES := debian prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-debian := $(call get_sha256,$(IMAGE_DEBIAN))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef IMAGE_RABBITMQ_INIT
  IMAGE_RABBITMQ_INIT_FIELD = , "rabbitmq.initImage": "$(IMAGE_RABBITMQ_INIT)"
endif

ifdef REPLICAS
  REPLICAS_FIELD = , "rabbitmq.replicas": "$(REPLICAS)"
endif

ifdef RABBITMQ_ERLANG_COOKIE
  RABBITMQ_ERLANG_COOKIE_FIELD = , "rabbitmq.erlangCookie": "$(RABBITMQ_ERLANG_COOKIE)"
endif

ifdef RABBITMQ_DEFAULT_USER
  RABBITMQ_DEFAULT_USER_FIELD = , "rabbitmq.user": "$(RABBITMQ_DEFAULT_USER)"
endif

ifdef RABBITMQ_DEFAULT_PASS
  RABBITMQ_DEFAULT_PASS_FIELD = , "rabbitmq.password": "$(RABBITMQ_DEFAULT_PASS)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_RABBITMQ_INIT_FIELD) \
  $(REPLICAS_FIELD) \
  $(RABBITMQ_ERLANG_COOKIE_FIELD) \
  $(RABBITMQ_DEFAULT_USER_FIELD) \
  $(RABBITMQ_DEFAULT_PASS_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
