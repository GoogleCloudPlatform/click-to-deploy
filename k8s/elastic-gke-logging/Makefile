include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_ID ?= elastic-gke-logging-managed-updates
VERIFY_WAIT_TIMEOUT = 1200


SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 6.3

# Images have tags and var_tag:
KIBANA_TAG ?= 6.3
FLUENTD_TAG ?= 1.2
METRICS_EXPORTER_TAG ?= v0.5.1

# List of images used in application
TARGET_IMAGES := kibana fluentd ubuntu16_04 prometheus-to-sd

# Image variable names should correspond with TARGET_IMAGES list
image-$(APP_ID) := $(call get_sha256,marketplace.gcr.io/google/elasticsearch6:$(TRACK))
image-kibana :=  $(call get_sha256,marketplace.gcr.io/google/kibana6:$(KIBANA_TAG))
image-fluentd :=  $(call get_sha256,marketplace.gcr.io/google/fluentd1:$(FLUENTD_TAG))
image-ubuntu16_04 :=  $(call get_sha256,marketplace.gcr.io/google/ubuntu1604:latest)
image-prometheus-to-sd :=  $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(APP_ID)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1

ifdef ELASTICSEARCH_REPLICAS
  ELASTICSEARCH_REPLICAS_FIELD = , "elasticsearch.replicas": "$(ELASTICSEARCH_REPLICAS)"
endif

ifdef IMAGE_INIT
  IMAGE_INIT_FIELD = , "initImage": "$(IMAGE_INIT)"
endif

ifdef IMAGE_KIBANA
  IMAGE_KIBANA_FIELD = , "kibana.image": "$(IMAGE_KIBANA)"
endif

ifdef IMAGE_FLUENTD
  IMAGE_FLUENTD_FIELD = , "fluentd.image": "$(IMAGE_FLUENTD)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(ELASTICSEARCH_REPLICAS_FIELD) \
  $(IMAGE_INIT_FIELD) \
  $(IMAGE_KIBANA_FIELD) \
  $(IMAGE_FLUENTD_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}


# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

