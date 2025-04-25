include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := gitlab
APP_ID ?= $(CHART_NAME)

VERIFY_WAIT_TIMEOUT = 1800

TRACK ?= 17.5
SERVICE_NAME := services/9f0fe022-a66a-4133-8099-f0ca7c61a2db.cloudpartnerservices.goog
POSTGRESQL_TAG ?= latest
POSTGRESQL_EXPORTER_TAG ?= latest
REDIS_TAG ?= 7.2
REDIS_EXPORTER_TAG ?= 1.63
METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_GITLAB ?= $(SOURCE_REGISTRY)/gitlab17:$(TRACK)
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql13:$(POSTGRESQL_TAG)
IMAGE_POSTGRESQL_EXPORTER ?= $(SOURCE_REGISTRY)/postgresql-exporter0:$(POSTGRESQL_EXPORTER_TAG)
IMAGE_REDIS ?= $(SOURCE_REGISTRY)/redis7:$(REDIS_TAG)
IMAGE_REDIS_EXPORTER ?= $(SOURCE_REGISTRY)/redis-exporter1:$(REDIS_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_GITLAB))

# List of images used in application
ADDITIONAL_IMAGES := postgresql postgresql-exporter redis redis-exporter prometheus-to-sd

## Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-postgresql := $(call get_sha256,$(IMAGE_POSTGRESQL))
image-redis := $(call get_sha256,$(IMAGE_REDIS))
image-postgresql-exporter := $(call get_sha256,$(IMAGE_POSTGRESQL_EXPORTER))
image-redis := $(call get_sha256,$(IMAGE_REDIS))
image-redis-exporter := $(call get_sha256,$(IMAGE_REDIS_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef DOMAIN_NAME
   DOMAIN_NAME_FIELD = , "gitlab.domainName": "$(DOMAIN_NAME)"
endif

ifdef SSL_CONFIGURATION
   SSL_CONFIGURATION_FIELD = , "gitlab.sslConfiguration": "$(SSL_CONFIGURATION)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif


APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(DOMAIN_NAME_FIELD) \
  $(SSL_CONFIGURATION_FIELD) \
}


# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
