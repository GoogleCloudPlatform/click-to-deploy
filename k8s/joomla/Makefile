include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= joomla
SOURCE_REGISTRY ?= marketplace.gcr.io/google

ifndef SOURCE_IMAGE
  $(info ---- SOURCE_REGISTRY = $(SOURCE_REGISTRY))
endif

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/joomla/VERSION` target to fill the RELEASE variable.
JOOMLA_TAG ?= sha256:fa54bc0e71f1f3a1fd3a0c8d9b66cd959ef9292bdd3a829d48de58a9a87e8989
METRICS_EXPORTER_TAG ?= v0.5.1
SOURCE_IMAGE ?= $(SOURCE_REGISTRY)/joomla3@$(joomla_TAG)

IMAGE_APACHE_EXPORTER ?= $(SOURCE_REGISTRY)/wordpress/apache-exporter:latest
MARIADB_IMAGE ?= $(SOURCE_REGISTRY)/mariadb10:latest
IMAGE_MYSQL_EXPORTER ?= $(SOURCE_REGISTRY)/wordpress/mysqld-exporter:latest

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 3.9
RELEASE ?= 3.9.11-$(BUILD_ID)

VERIFY_WAIT_TIMEOUT = 1800

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))
$(info ---- SOURCE_IMAGE = $(SOURCE_IMAGE))
$(info ---- APP_IMAGE = $(REGISTRY)/$(APP_ID):$(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef PUBLIC_SERVICE_AND_INGRESS_ENABLED
  PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD = , "enablePublicServiceAndIngress": $(PUBLIC_SERVICE_AND_INGRESS_ENABLED)
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/joomla/deployer \
            .build/joomla/joomla \
            .build/joomla/prometheus-to-sd \
            .build/joomla/apache-exporter \
            .build/joomla/mysqld-exporter \
            .build/joomla/mariadb \
            .build/joomla/tester \
            .build/joomla/VERSION


.build/joomla: | .build
	mkdir -p "$@"


.PHONY: .build/joomla/VERSION
.build/joomla/VERSION:
	# exit 1


.build/joomla/deployer: deployer/* \
                      chart/joomla/* \
                      chart/joomla/templates/* \
                      schema.yaml \
                      .build/var/APP_DEPLOYER_IMAGE \
                      .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                      .build/var/MARKETPLACE_TOOLS_TAG \
                      .build/var/REGISTRY \
                      .build/var/TRACK \
                      .build/var/RELEASE \
                      | .build/joomla
	docker build \
			--build-arg REGISTRY="$(REGISTRY)/$(APP_ID)" \
			--build-arg TAG="$(RELEASE)" \
			--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
			--tag "$(APP_DEPLOYER_IMAGE)" \
			-f deployer/Dockerfile \
			.
	docker tag "$(APP_DEPLOYER_IMAGE)" "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/joomla/joomla: .build/var/REGISTRY \
                  .build/var/TRACK \
                  .build/var/RELEASE \
                  | .build/joomla
	docker pull $(SOURCE_IMAGE)
	docker tag $(SOURCE_IMAGE) \
			"$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
			"$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/joomla/prometheus-to-sd: .build/var/REGISTRY \
                              .build/var/TRACK \
                              .build/var/RELEASE \
                              | .build/joomla
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
			"$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
			"$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"

.build/joomla/apache-exporter: .build/var/REGISTRY \
                              .build/var/TRACK \
                              .build/var/RELEASE \
                              | .build/joomla
	docker pull $(IMAGE_APACHE_EXPORTER)
	docker tag $(IMAGE_APACHE_EXPORTER) \
			"$(REGISTRY)/$(APP_ID)/apache-exporter:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/apache-exporter:$(TRACK)" \
			"$(REGISTRY)/$(APP_ID)/apache-exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/apache-exporter:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/apache-exporter:$(RELEASE)"
	@touch "$@"

.build/joomla/mysqld-exporter: .build/var/REGISTRY \
                              .build/var/TRACK \
                              .build/var/RELEASE \
                              | .build/joomla
	docker pull $(IMAGE_MYSQL_EXPORTER)
	docker tag $(IMAGE_MYSQL_EXPORTER) \
			"$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)" \
			"$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	@touch "$@"

.build/joomla/mariadb: .build/var/REGISTRY \
                              .build/var/TRACK \
                              .build/var/RELEASE \
                              | .build/joomla
	docker pull $(MARIADB_IMAGE)
	docker tag $(MARIADB_IMAGE) \
			"$(REGISTRY)/$(APP_ID)/mariadb:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/mariadb:$(TRACK)" \
			"$(REGISTRY)/$(APP_ID)/mariadb:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/mariadb:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/mariadb:$(RELEASE)"
	@touch "$@"


.build/joomla/tester: .build/var/TESTER_IMAGE \
                    $(shell find apptest -type f) \
                    | .build/joomla
	$(call print_target,$@)
	cd apptest/tester \
			&& docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
