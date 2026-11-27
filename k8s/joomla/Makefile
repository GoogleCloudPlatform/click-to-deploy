include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME ?= joomla
APP_ID ?= $(CHART_NAME)

TRACK ?= 4.4
SERVICE_NAME := services/012bd695-77ae-4119-a8d1-371a93102f64.cloudpartnerservices.goog

APACHE_EXPORTER_TAG ?= 0.13
METRICS_EXPORTER_TAG ?= v0.11.1-gke.1
MARIADB_TAG ?= 11.1
MYSQLD_EXPORTER_TAG ?= exporter

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_JOOMLA ?= $(SOURCE_REGISTRY)/joomla4-php8-apache:$(TRACK)
IMAGE_MARIADB ?= $(SOURCE_REGISTRY)/mariadb11:$(MARIADB_TAG)
IMAGE_APACHE_EXPORTER ?= $(SOURCE_REGISTRY)/apache-exporter0:$(APACHE_EXPORTER_TAG)
IMAGE_MYSQLD_EXPORTER ?= $(SOURCE_REGISTRY)/mysql8:$(MYSQLD_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_JOOMLA))

# List of images used in application
# prometheus-to-sd is published via buildx below so OCI index and manifest carry
# com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME).
ADDITIONAL_IMAGES := mariadb apache-exporter mysqld-exporter
ANNOTATED_IMAGES := prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-mariadb := $(call get_sha256,$(IMAGE_MARIADB))
image-apache-exporter := $(call get_sha256,$(IMAGE_APACHE_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))
image-mysqld-exporter := $(call get_sha256,$(IMAGE_MYSQLD_EXPORTER))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef PUBLIC_SERVICE_AND_INGRESS_ENABLED
  PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD = , "enablePublicServiceAndIngress": $(PUBLIC_SERVICE_AND_INGRESS_ENABLED)
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

ANNOTATED_IMAGE_TARGETS = $(patsubst %,.build/$(CHART_NAME)/annotated-%,$(ANNOTATED_IMAGES))

$(ANNOTATED_IMAGE_TARGETS): .build/$(CHART_NAME)/annotated-%: .build/var/REGISTRY \
                                                             .build/var/TRACK \
                                                             .build/var/RELEASE \
                                                             | .build/$(CHART_NAME)
	$(call print_target,$*)
	IMAGE_BUILDER="image-builder-$$(openssl rand -base64 12 | tr -dc 'a-z0-9' | head -c 8)"; \
	docker buildx create --name "$$IMAGE_BUILDER" \
		&& docker buildx inspect "$$IMAGE_BUILDER" --bootstrap \
		&& printf 'FROM %s\n' "$(image-$*)" | docker buildx build \
			--builder "$$IMAGE_BUILDER" \
			--push \
			--annotation="index,manifest:com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME)" \
			--tag "$(REGISTRY)/$(APP_ID)/$*:$(TRACK)" \
			--tag "$(REGISTRY)/$(APP_ID)/$*:$(RELEASE)" \
			- ; \
	BUILD_STATUS=$$?; \
	docker buildx rm "$$IMAGE_BUILDER" || true; \
	exit $$BUILD_STATUS
	@touch "$@"


# Build annotated images
app/build:: $(ANNOTATED_IMAGE_TARGETS)

# Build tester image
app/build:: .build/$(CHART_NAME)/tester
