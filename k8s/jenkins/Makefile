include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_NAME ?= jenkins
APP_ID ?= $(APP_NAME)-managed-updates
VERIFY_WAIT_TIMEOUT = 1800


SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 2.176

# Images have tags and var_tag:

# List of images used in application
TARGET_IMAGES :=

# Image variable names should correspond with TARGET_IMAGES list
JENKINS_TAG := sha256:87f38f32fd9bed856934144bed9bfd16d4a624c5a1504e808bf1532de564c571
image-$(APP_NAME) := gcr.io/cloud-marketplace/google/jenkins2@$(JENKINS_TAG)
# TODO(kalinichenka): replace with proper TRACK
#image-$(APP_NAME) := $(call get_sha256,$(SOURCE_REGISTRY)/jenkins2:$(TRACK))

# TODO(kalinichenka): Replace with C2D_RELEASE variable after container is updated.
# C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(APP_NAME)))
C2D_CONTAINER_RELEASE := $(call get_var_from_container,$(image-$(APP_NAME)),JENKINS_VERSION)

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

