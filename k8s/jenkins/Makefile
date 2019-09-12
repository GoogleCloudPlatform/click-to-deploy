include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_ID ?= jenkins-managed-updates
VERIFY_WAIT_TIMEOUT = 1800


SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 2.176

# Images have tags and var_tag:

# List of images used in application
TARGET_IMAGES :=

# Image variable names should correspond with TARGET_IMAGES list
image-$(APP_ID) := $(call get_sha256,marketplace.gcr.io/google/jenkins2:$(TRACK))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(APP_ID)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

