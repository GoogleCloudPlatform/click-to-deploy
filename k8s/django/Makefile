include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := django
APP_ID ?= $(CHART_NAME)

TRACK ?= 5.1
SERVICE_NAME := services/b0af85ce-23df-43aa-9f54-b6e81eeb27d1.cloudpartnerservices.goog
UWSGI_EXPORTER_TRACK ?= 1.3
NGINX_TRACK ?= 1.26
EXPORTER_TAG ?= 1.3
METRICS_EXPORTER_TAG ?= v0.5.1
NFS_TRACK ?= 1.3
POSTGRESQL_TRACK ?= latest
POSTGRESQL_EXPORTER_TRACK ?= 0.15

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_DJANGO ?= $(SOURCE_REGISTRY)/django5:$(TRACK)
IMAGE_UWSGI_EXPORTER ?= $(SOURCE_REGISTRY)/uwsgi-exporter1:$(UWSGI_EXPORTER_TRACK)
IMAGE_NGINX ?= $(SOURCE_REGISTRY)/nginx1:$(NGINX_TRACK)
IMAGE_NGINX_EXPORTER = $(SOURCE_REGISTRY)/nginx-exporter1:$(EXPORTER_TAG)
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql13:$(POSTGRESQL_TRACK)
IMAGE_POSTGRESQL_EXPORTER = $(SOURCE_REGISTRY)/postgresql-exporter0:$(POSTGRESQL_EXPORTER_TRACK)
IMAGE_NFS ?= $(SOURCE_REGISTRY)/nfs-server1:$(NFS_TRACK)
IMAGE_DEBIAN ?= $(SOURCE_REGISTRY)/debian12:latest
IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_DJANGO))

# List of images used in application
ADDITIONAL_IMAGES := uwsgi-exporter nginx debian nginx-exporter postgresql postgresql-exporter nfs prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-debian :=  $(call get_sha256,$(IMAGE_DEBIAN))
image-uwsgi-exporter := $(call get_sha256,$(IMAGE_UWSGI_EXPORTER))
image-nginx := $(call get_sha256, $(IMAGE_NGINX))
image-nginx-exporter := $(call get_sha256,$(IMAGE_NGINX_EXPORTER))
image-postgresql := $(call get_sha256, $(IMAGE_POSTGRESQL))
image-postgresql-exporter := $(call get_sha256,$(IMAGE_POSTGRESQL_EXPORTER))
image-nfs := $(call get_sha256,$(IMAGE_NFS))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

ifdef IMAGE_NGINX_INIT
  IMAGE_NGINX_INIT_FIELD = , "nginx.initImage": "$(IMAGE_NGINX_INIT)"
endif

ifdef PUBLIC_IP_AVAILABLE
  PUBLIC_IP_AVAILABLE_FIELD = , "publicIp.available": $(PUBLIC_IP_AVAILABLE)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_NGINX_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(PUBLIC_IP_AVAILABLE_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
