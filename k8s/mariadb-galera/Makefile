include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_ID ?= mariadb-galera
VERIFY_WAIT_TIMEOUT = 1800

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/mariadb-galera/VERSION` target to fill the RELEASE variable.

TRACK ?= 10.3

METRICS_EXPORTER_TAG ?= v0.5.1
PEER_FINDER_TAG ?= latest

TARGETS := mysqld-exporter prometheus-to-sd peer-finder


# Images
image-$(APP_ID) ?= $(call get_sha256,$(SOURCE_REGISTRY)/mariadb10:$(TRACK))
image-mysqld-exporter ?= $(call get_sha256,$(SOURCE_REGISTRY)/mysql5:exporter)
image-peer-finder ?= $(call get_sha256,$(SOURCE_REGISTRY)/peer-finder0:$(PEER_FINDER_TAG))
image-prometheus-to-sd ?= $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE ?= $(call get_var_from_container,$(image-$(APP_ID)) ,MARIADB_VERSION)

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)


# Additional variables
ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "prometheusToSd.enabled": $(METRICS_EXPORTER_ENABLED)
endif

NAME ?= $(APP_ID)-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2_2.Makefile

.PHONY: .build/$(APP_ID)/VERSION
.build/$(APP_ID)/VERSION:
	[[ "$(C2D_CONTAINER_RELEASE)" =~ ^$(TRACK)\..* ]] || \
	( echo "C2D_RELEASE don't starts with TRACK or matchs TRACK exactly"; exit 1 )
