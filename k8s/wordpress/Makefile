include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := wordpress
APP_ID ?= $(CHART_NAME)
VERIFY_WAIT_TIMEOUT = 1700

SERVICE_NAME := services/d60f6935-b4e7-46b3-8f96-eece88c7cd42.cloudpartnerservices.goog
TRACK ?= 6.6

METRICS_EXPORTER_TAG ?= v0.5.1
APACHE_EXPORTER_TAG ?= 0.13
MARIADB_TAG ?= 11.1

SOURCE_REGISTRY ?= marketplace.gcr.io/google
IMAGE_WORDPRESS ?= $(SOURCE_REGISTRY)/wordpress6-php8-apache:$(TRACK)
IMAGE_APACHE_EXPORTER ?= $(SOURCE_REGISTRY)/apache-exporter0:$(APACHE_EXPORTER_TAG)
IMAGE_MYSQL ?= $(SOURCE_REGISTRY)/mariadb11:$(MARIADB_TAG)
IMAGE_MYSQLD_EXPORTER ?= $(SOURCE_REGISTRY)/mysql8:exporter
IMAGE_PROMETHEUS_TO_SD ?= eu.gcr.io/k8s-artifacts-prod/prometheus-to-sd:$(METRICS_EXPORTER_TAG)


# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_WORDPRESS))

# List of images used in application
ADDITIONAL_IMAGES := apache-exporter mysql mysqld-exporter prometheus-to-sd

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-apache-exporter := $(call get_sha256,$(IMAGE_APACHE_EXPORTER))
image-mysql := $(call get_sha256,$(IMAGE_MYSQL))
image-mysqld-exporter := $(call get_sha256,$(IMAGE_MYSQLD_EXPORTER))
image-prometheus-to-sd := $(call get_sha256,$(IMAGE_PROMETHEUS_TO_SD))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef ROOT_DB_PASSWORD
  ROOT_DB_PASSWORD_FIELD = , "db.rootPassword": "$(ROOT_DB_PASSWORD)"
endif

ifdef WORDPRESS_DB_PASSWORD
  WORDPRESS_DB_PASSWORD_FIELD = , "db.wordpressPassword": "$(WORDPRESS_DB_PASSWORD)"
endif

ifdef WORDPRESS_ADMIN_EMAIL
  WORDPRESS_ADMIN_EMAIL_FIELD = , "admin.email": "$(WORDPRESS_ADMIN_EMAIL)"
endif

ifdef WORDPRESS_ADMIN_PASSWORD
  WORDPRESS_ADMIN_PASSWORD_FIELD = , "admin.password": "$(WORDPRESS_ADMIN_PASSWORD)"
endif

ifdef PUBLIC_SERVICE_AND_INGRESS_ENABLED
  PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD = , "enablePublicServiceAndIngress": $(PUBLIC_SERVICE_AND_INGRESS_ENABLED)
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.exporter.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(ROOT_DB_PASSWORD_FIELD) \
  $(WORDPRESS_DB_PASSWORD_FIELD) \
  $(WORDPRESS_ADMIN_EMAIL_FIELD) \
  $(WORDPRESS_ADMIN_PASSWORD_FIELD) \
  $(PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
