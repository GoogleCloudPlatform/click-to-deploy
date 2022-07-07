include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := harbor
APP_ID ?= $(CHART_NAME)

TRACK ?= 2.5
HARBOR_TRACK ?= v2.5.2

# EXPORTER_TAG ?= 0.7
# METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

VERIFY_WAIT_TIMEOUT = 1800

# SOURCE_REGISTRY ?= marketplace.gcr.io/google
SOURCE_REGISTRY ?= mattjcontainerregistry
HARBOR_SOURCE_REGISTRY ?= goharbor

IMAGE_HARBOR ?= $(SOURCE_REGISTRY)/harbor-core:$(TRACK)

# Additionall images
IMAGE_HARBOR_CHARTMUSEUM ?= $(HARBOR_SOURCE_REGISTRY)/chartmuseum-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_DATABASE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-db:$(HARBOR_TRACK)
IMAGE_HARBOR_JOBSERVICE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-jobservice:$(HARBOR_TRACK)
IMAGE_HARBOR_NOTARY_SERVER ?= $(HARBOR_SOURCE_REGISTRY)/notary-server-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_NOTARY_SIGNER ?= $(HARBOR_SOURCE_REGISTRY)/notary-signer-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_PORTAL ?= $(HARBOR_SOURCE_REGISTRY)/harbor-portal:$(HARBOR_TRACK)
IMAGE_HARBOR_REDIS ?= $(HARBOR_SOURCE_REGISTRY)/redis-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_REGISTRY ?= $(HARBOR_SOURCE_REGISTRY)/registry-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_REGISTRYCTL ?= $(HARBOR_SOURCE_REGISTRY)/harbor-registryctl:$(HARBOR_TRACK)
IMAGE_HARBOR_TRIVY ?= $(HARBOR_SOURCE_REGISTRY)/trivy-adapter-photon:$(HARBOR_TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_HARBOR))

# List of images used in application
ADDITIONAL_IMAGES := harbor-chartmuseum harbor-database harbor-jobservice harbor-notary-server harbor-notary-signer harbor-portal harbor-redis harbor-registry harbor-registryctl harbor-trivy

# Additional images variable names should correspond with ADDITIONAL_IMAGES list

image-harbor-chartmuseum := $(call get_sha256,$(IMAGE_HARBOR_CHARTMUSEUM))
image-harbor-database := $(call get_sha256,$(IMAGE_HARBOR_DATABASE))
image-harbor-jobservice := $(call get_sha256,$(IMAGE_HARBOR_JOBSERVICE))
image-harbor-notary-server := $(call get_sha256,$(IMAGE_HARBOR_NOTARY_SERVER))
image-harbor-notary-signer := $(call get_sha256,$(IMAGE_HARBOR_NOTARY_SIGNER))
image-harbor-portal := $(call get_sha256,$(IMAGE_HARBOR_PORTAL))
image-harbor-redis := $(call get_sha256,$(IMAGE_HARBOR_REDIS))
image-harbor-registry := $(call get_sha256,$(IMAGE_HARBOR_REGISTRY))
image-harbor-registryctl := $(call get_sha256,$(IMAGE_HARBOR_REGISTRYCTL))
image-harbor-trivy := $(call get_sha256,$(IMAGE_HARBOR_TRIVY))

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
