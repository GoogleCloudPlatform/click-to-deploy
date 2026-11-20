include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := harbor
APP_ID ?= $(CHART_NAME)

TRACK ?= 2.15
HARBOR_TRACK ?= v2.15.5
SERVICE_NAME := services/4f189f69-8da4-4dc9-8b0c-70cf55bef567.cloudpartnerservices.goog

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google
HARBOR_SOURCE_REGISTRY ?= goharbor
NGINX_TRACK ?= 1.30
METRICS_EXPORTER_TAG ?= v0.12.12-gke.13

IMAGE_HARBOR ?= $(SOURCE_REGISTRY)/harbor2:$(TRACK)
IMAGE_NGINX_BASE ?= $(SOURCE_REGISTRY)/nginx1:$(NGINX_TRACK)

# Upstream images re-published with USG service annotation
IMAGE_HARBOR_CORE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-core:$(HARBOR_TRACK)
IMAGE_HARBOR_DATABASE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-db:$(HARBOR_TRACK)
IMAGE_HARBOR_EXPORTER ?= $(HARBOR_SOURCE_REGISTRY)/harbor-exporter:$(HARBOR_TRACK)
IMAGE_HARBOR_JOBSERVICE ?= $(HARBOR_SOURCE_REGISTRY)/harbor-jobservice:$(HARBOR_TRACK)
IMAGE_HARBOR_PORTAL ?= $(HARBOR_SOURCE_REGISTRY)/harbor-portal:$(HARBOR_TRACK)
IMAGE_HARBOR_REDIS ?= $(HARBOR_SOURCE_REGISTRY)/valkey-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_REGISTRY ?= $(HARBOR_SOURCE_REGISTRY)/registry-photon:$(HARBOR_TRACK)
IMAGE_HARBOR_REGISTRYCTL ?= $(HARBOR_SOURCE_REGISTRY)/harbor-registryctl:$(HARBOR_TRACK)
IMAGE_HARBOR_TRIVY ?= $(HARBOR_SOURCE_REGISTRY)/trivy-adapter-photon:$(HARBOR_TRACK)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_HARBOR))

# Upstream images are pushed via buildx below so OCI index and manifest carry
# com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME).
# nginx and portal are built from local Dockerfiles onto marketplace.gcr.io/google/nginx1:$(NGINX_TRACK).
ADDITIONAL_IMAGES :=
ANNOTATED_IMAGES := core database exporter jobservice redis registry registryctl trivy prometheus-to-sd

image-core := $(call get_sha256,$(IMAGE_HARBOR_CORE))
image-database := $(call get_sha256,$(IMAGE_HARBOR_DATABASE))
image-exporter := $(call get_sha256,$(IMAGE_HARBOR_EXPORTER))
image-jobservice := $(call get_sha256,$(IMAGE_HARBOR_JOBSERVICE))
image-redis := $(call get_sha256,$(IMAGE_HARBOR_REDIS))
image-registry := $(call get_sha256,$(IMAGE_HARBOR_REGISTRY))
image-registryctl := $(call get_sha256,$(IMAGE_HARBOR_REGISTRYCTL))
image-trivy := $(call get_sha256,$(IMAGE_HARBOR_TRIVY))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

image-nginx-base := $(call get_sha256,$(IMAGE_NGINX_BASE))
image-portal-assets := $(call get_sha256,$(IMAGE_HARBOR_PORTAL))

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

ANNOTATED_IMAGE_TARGETS = $(patsubst %,.build/$(CHART_NAME)/annotated-%,$(ANNOTATED_IMAGES))

$(ANNOTATED_IMAGE_TARGETS): .build/$(CHART_NAME)/annotated-%: .build/var/REGISTRY \
                                                             .build/var/TRACK \
                                                             .build/var/RELEASE \
                                                             | .build/$(CHART_NAME)
	$(call print_target,$*)
	IMAGE_BUILDER="image-builder-$$(openssl rand -base64 12 | tr -dc 'a-z0-9' | head -c 8)"; \
	docker buildx create --name "$$IMAGE_BUILDER" --use \
		&& docker buildx inspect "$$IMAGE_BUILDER" --bootstrap \
		&& printf 'FROM %s\n' "$(image-$*)" | docker buildx build \
			--push \
			--annotation="index,manifest:com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME)" \
			--tag "$(REGISTRY)/$(APP_ID)/$*:$(TRACK)" \
			--tag "$(REGISTRY)/$(APP_ID)/$*:$(RELEASE)" \
			- ; \
	BUILD_STATUS=$$?; \
	docker buildx rm "$$IMAGE_BUILDER" || true; \
	exit $$BUILD_STATUS
	@touch "$@"

.build/$(CHART_NAME)/nginx: nginx/Dockerfile \
                            .build/var/REGISTRY \
                            .build/var/TRACK \
                            .build/var/RELEASE \
                            | .build/$(CHART_NAME)
	$(call print_target,$@)
	NGINX_BUILDER="nginx-builder-$$(openssl rand -base64 12 | tr -dc 'a-z0-9' | head -c 8)"; \
	docker buildx create --name "$$NGINX_BUILDER" --use \
		&& docker buildx inspect "$$NGINX_BUILDER" --bootstrap \
		&& docker buildx build \
			--push \
			--annotation="index,manifest:com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME)" \
			--build-arg NGINX_IMAGE="$(image-nginx-base)" \
			--tag "$(REGISTRY)/$(APP_ID)/nginx:$(TRACK)" \
			--tag "$(REGISTRY)/$(APP_ID)/nginx:$(RELEASE)" \
			-f nginx/Dockerfile \
			nginx ; \
	BUILD_STATUS=$$?; \
	docker buildx rm "$$NGINX_BUILDER" || true; \
	exit $$BUILD_STATUS
	@touch "$@"

.build/$(CHART_NAME)/portal: portal/Dockerfile \
                             .build/var/REGISTRY \
                             .build/var/TRACK \
                             .build/var/RELEASE \
                             | .build/$(CHART_NAME)
	$(call print_target,$@)
	PORTAL_BUILDER="portal-builder-$$(openssl rand -base64 12 | tr -dc 'a-z0-9' | head -c 8)"; \
	docker buildx create --name "$$PORTAL_BUILDER" --use \
		&& docker buildx inspect "$$PORTAL_BUILDER" --bootstrap \
		&& docker buildx build \
			--push \
			--annotation="index,manifest:com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME)" \
			--build-arg NGINX_IMAGE="$(image-nginx-base)" \
			--build-arg HARBOR_PORTAL_IMAGE="$(image-portal-assets)" \
			--tag "$(REGISTRY)/$(APP_ID)/portal:$(TRACK)" \
			--tag "$(REGISTRY)/$(APP_ID)/portal:$(RELEASE)" \
			-f portal/Dockerfile \
			portal ; \
	BUILD_STATUS=$$?; \
	docker buildx rm "$$PORTAL_BUILDER" || true; \
	exit $$BUILD_STATUS
	@touch "$@"

# Build annotated upstream images, patched nginx/portal wrappers, and tester image
app/build:: $(ANNOTATED_IMAGE_TARGETS) \
            .build/$(CHART_NAME)/nginx \
            .build/$(CHART_NAME)/portal \
            .build/$(CHART_NAME)/tester
