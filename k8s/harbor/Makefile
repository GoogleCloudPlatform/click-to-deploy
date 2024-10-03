include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := harbor
APP_ID ?= $(CHART_NAME)

TRACK ?= 2.11
HARBOR_TRACK ?= v2.11.0

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google
HARBOR_SOURCE_REGISTRY ?= goharbor
PHOTON_TRACK ?= v2.7.4
METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

IMAGE_HARBOR ?= $(SOURCE_REGISTRY)/harbor2:$(TRACK)

# Additional images
IMAGE_HARBOR_CORE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-core:$(HARBOR_TRACK)
IMAGE_HARBOR_CHARTMUSEUM ?= $(HARBOR_SOURCE_REGISTRY)/chartmuseum-photon:$(PHOTON_TRACK)
IMAGE_HARBOR_DATABASE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-db:$(PHOTON_TRACK)
IMAGE_HARBOR_EXPORTER ?= $(HARBOR_SOURCE_REGISTRY)/harbor-exporter:$(HARBOR_TRACK)
IMAGE_HARBOR_JOBSERVICE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-jobservice:$(HARBOR_TRACK)
IMAGE_HARBOR_NOTARY_SERVER ?= $(HARBOR_SOURCE_REGISTRY)/notary-server-photon:$(PHOTON_TRACK)
IMAGE_HARBOR_NOTARY_SIGNER ?= $(HARBOR_SOURCE_REGISTRY)/notary-signer-photon:$(PHOTON_TRACK)
IMAGE_HARBOR_PORTAL ?= $(HARBOR_SOURCE_REGISTRY)/harbor-portal:$(HARBOR_TRACK)
IMAGE_HARBOR_REDIS ?= $(HARBOR_SOURCE_REGISTRY)/redis-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_REGISTRY ?= $(HARBOR_SOURCE_REGISTRY)/registry-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_REGISTRYCTL ?= $(HARBOR_SOURCE_REGISTRY)/harbor-registryctl:$(HARBOR_TRACK)
IMAGE_HARBOR_TRIVY ?= $(HARBOR_SOURCE_REGISTRY)/trivy-adapter-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_NGINX ?= $(HARBOR_SOURCE_REGISTRY)/nginx-photon:$(PHOTON_TRACK)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_HARBOR))

# List of images used in application
ADDITIONAL_IMAGES := core chartmuseum database exporter jobservice notary-server notary-signer portal redis registry registryctl trivy nginx prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-core := $(call get_sha256,$(IMAGE_HARBOR_CORE))
image-chartmuseum := $(call get_sha256,$(IMAGE_HARBOR_CHARTMUSEUM))
image-database := $(call get_sha256,$(IMAGE_HARBOR_DATABASE))
image-exporter := $(call get_sha256,$(IMAGE_HARBOR_EXPORTER))
image-jobservice := $(call get_sha256,$(IMAGE_HARBOR_JOBSERVICE))
image-notary-server := $(call get_sha256,$(IMAGE_HARBOR_NOTARY_SERVER))
image-notary-signer := $(call get_sha256,$(IMAGE_HARBOR_NOTARY_SIGNER))
image-portal := $(call get_sha256,$(IMAGE_HARBOR_PORTAL))
image-redis := $(call get_sha256,$(IMAGE_HARBOR_REDIS))
image-registry := $(call get_sha256,$(IMAGE_HARBOR_REGISTRY))
image-registryctl := $(call get_sha256,$(IMAGE_HARBOR_REGISTRYCTL))
image-trivy := $(call get_sha256,$(IMAGE_HARBOR_TRIVY))
image-nginx := $(call get_sha256,$(IMAGE_HARBOR_NGINX))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
