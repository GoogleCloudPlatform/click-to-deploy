include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_ID ?= grafana-managed-updates

SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 5.3

# Images have tags and var_tag:
METRICS_EXPORTER_TAG ?= v0.5.1

# List of images used in application
TARGET_IMAGES := debian9 prometheus-to-sd

# Image variable names should correspond with TARGET_IMAGES list
image-$(APP_ID) := $(call get_sha256,marketplace.gcr.io/google/grafana5:$(TRACK))
image-debian9 :=  $(call get_sha256,marketplace.gcr.io/google/debian9:latest)
image-prometheus-to-sd :=  $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(APP_ID)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1

ifdef IMAGE_GRAFANA_INIT
  IMAGE_GRAFANA_INIT_FIELD = , "grafana.initImage": "$(IMAGE_GRAFANA_INIT)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_GRAFANA_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

