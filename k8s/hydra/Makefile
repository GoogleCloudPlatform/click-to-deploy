include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := hydra
APP_ID ?= $(CHART_NAME)

TRACK ?= 2.1
POSTGRESQL_TAG ?= latest
POSTGRESQL_EXPORTER_TAG ?= latest
METRICS_EXPORTER_TAG ?= v0.11.1-gke.1

VERIFY_WAIT_TIMEOUT = 1800

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_HYDRA ?= $(SOURCE_REGISTRY)/hydra2:$(TRACK)
IMAGE_POSTGRESQL ?= $(SOURCE_REGISTRY)/postgresql13:$(POSTGRESQL_TAG)
IMAGE_POSTGRESQL_EXPORTER ?= $(SOURCE_REGISTRY)/postgresql-exporter0:$(POSTGRESQL_EXPORTER_TAG)
IMAGE_PROMETHEUS_TO_SD ?= gke.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_HYDRA))

# List of images used in application
ADDITIONAL_IMAGES := postgresql postgresql-exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-postgresql := $(call get_sha256,$(IMAGE_POSTGRESQL))
image-postgresql-exporter := $(call get_sha256,$(IMAGE_POSTGRESQL_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef INGRESS_PUBLIC_ENABLED
  INGRESS_PUBLIC_ENABLED_FIELD = , "ingress.public.enabled": $(METRICS_EXPORTER_ENABLED)
endif

ifdef INGRESS_ADMIN_ENABLED
  INGRESS_ADMIN_ENABLED_FIELD = , "ingress.admin.enabled": $(INGRESS_PUBLIC_ENABLED)
endif

ifdef FORCE_HTTP_ENABLED
  FORCE_HTTP_ENABLED_FIELD = , "hydra.dangerousForceHttp": $(FORCE_HTTP_ENABLED)
endif

ifdef URLS_LOGIN
  URLS_LOGIN_FIELD = , "hydra.config.urls.login": $(URLS_LOGIN)
endif

ifdef URLS_LOGOUT
  URLS_LOGOUT_FIELD = , "hydra.config.urls.logout": $(URLS_LOGOUT)
endif

ifdef URLS_CONSENT
  URLS_CONSENT_FIELD = , "hydra.config.urls.consent": $(URLS_CONSENT)
endif

ifdef URLS_SELF_ISSUER
  URLS_SELF_ISSUER_FIELD = , "hydra.config.urls.self.issuer": $(URLS_SELF_ISSUER)
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(INGRESS_PUBLIC_ENABLED_FIELD) \
  $(INGRESS_ADMIN_ENABLED_FIELD) \
  $(FORCE_HTTP_ENABLED_FIELD) \
  $(URLS_LOGIN_FIELD) \
  $(URLS_LOGOUT_FIELD) \
  $(URLS_CONSENT_FIELD) \
  $(URLS_SELF_ISSUER_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
