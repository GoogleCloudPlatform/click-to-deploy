include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

APP_NAME ?= wordpress
APP_ID ?= $(APP_NAME)-managed-updates
VERIFY_WAIT_TIMEOUT = 1800


SOURCE_REGISTRY ?= marketplace.gcr.io/google

TRACK ?= 5.2

# Images have tags and var_tag:
MYSQL_TAG ?= latest
METRICS_EXPORTER_TAG ?= v0.5.1

# List of images used in application
TARGET_IMAGES := apache-exporter mysql mysqld-exporter prometheus-to-sd

# Image variable names should correspond with TARGET_IMAGES list
WP_TAG := sha256:477f43a01e1edf44c3f578976855ce5ad24da78fac401dd387f0e7461c187e74
image-$(APP_NAME) := gcr.io/cloud-marketplace/google/wordpress5-php7-apache@$(WP_TAG)
# TODO(kalinichenka): replace with 
#image-$(APP_NAME) := $(call get_sha256,marketplace.gcr.io/google/wordpress5-php7-apache:$(TRACK))

image-apache-exporter :=  $(call get_sha256,marketplace.gcr.io/google/wordpress5-php7-apache:exporter)
image-mysql :=  $(call get_sha256,marketplace.gcr.io/google/mysql5:$(MYSQL_TAG))
image-mysqld-exporter :=  $(call get_sha256,marketplace.gcr.io/google/mysql5:exporter)
image-prometheus-to-sd :=  $(call get_sha256,k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(APP_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)

NAME ?= $(APP_ID)-1

ifdef IMAGE_MYSQL
  IMAGE_MYSQL_FIELD = , "db.image": "$(IMAGE_MYSQL)"
endif

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
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_MYSQL_FIELD) \
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

