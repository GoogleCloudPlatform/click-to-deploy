include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := jenkins
APP_ID ?= $(CHART_NAME)
VERIFY_WAIT_TIMEOUT = 1800

TRACK ?= 2.222

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_JENKINS = $(SOURCE_REGISTRY)/jenkins2:$(TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_JENKINS))

# List of images used in application
ADDITIONAL_IMAGES :=

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
