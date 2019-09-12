include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_ID ?= sonarqube-managed-updates
VERIFY_WAIT_TIMEOUT = 600


SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 7.7

# Images have tags and var_tag:
POSTGRESQL_TAG ?= 9.6-kubernetes
METRICS_EXPORTER_TAG ?= v0.5.1

# List of images used in application
TARGET_IMAGES := postgresql postgresql-exporter prometheus-to-sd

# Image variable names should correspond with TARGET_IMAGES list
image-$(APP_ID) := $(call get_sha256,marketplace.gcr.io/google/sonarqube7:$(TRACK))
image-postgresql :=  $(call get_sha256,marketplace.gcr.io/google/postgresql9:$(POSTGRESQL_TAG))
image-postgresql-exporter :=  $(call get_sha256,marketplace.gcr.io/google/postgresql9:exporter)
image-prometheus-to-sd :=  $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(APP_ID)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1

ifdef DB_PASSWORD
  DB_PASSWORD_FIELD = , "postgresql.db.password": "$(DB_PASSWORD)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(DB_PASSWORD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile

