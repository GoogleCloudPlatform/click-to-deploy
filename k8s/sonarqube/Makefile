include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := sonarqube
APP_ID ?= $(CHART_NAME)

VERIFY_WAIT_TIMEOUT = 600

TRACK ?= 8.9

POSTGRESQL_TAG ?= 10.13
POSTGRESQL_EXPORTER_TAG ?= latest
METRICS_EXPORTER_TAG ?= v0.5.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_SONARQUBE ?= $(SOURCE_REGISTRY)/sonarqube8:$(TRACK)
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql10:$(POSTGRESQL_TAG)
IMAGE_POSTGRESQL_EXPORTER ?= $(SOURCE_REGISTRY)/postgresql-exporter0:$(POSTGRESQL_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_SONARQUBE))

# List of images used in application
ADDITIONAL_IMAGES := postgresql postgresql-exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-postgresql := $(call get_sha256,$(IMAGE_POSTGRESQL))
image-postgresql-exporter := $(call get_sha256,$(IMAGE_POSTGRESQL_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef DB_PASSWORD
  DB_PASSWORD_FIELD = , "postgresql.db.password": "$(DB_PASSWORD)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif


APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(DB_PASSWORD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
