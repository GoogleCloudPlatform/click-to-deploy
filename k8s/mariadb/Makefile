include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= mariadb-managed-updates

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/mariadb/VERSION` target to fill the RELEASE variable.
MARIADB_TAG ?= sha256:edc02d0c232098d9882eed8cacfdde63deb7be631894a9323d9471990890b3df
METRICS_EXPORTER_TAG ?= v0.5.1

TIMESTAMP := $(shell date +%s)
TRACK ?= 10.3
RELEASE ?= 10.3.15-build.$(TIMESTAMP)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/mariadb/deployer \
            .build/mariadb/mariadb \
            .build/mariadb/mysqld-exporter \
            .build/mariadb/prometheus-to-sd \
            .build/mariadb/tester \
            .build/mariadb/VERSION


.build/mariadb: | .build
	mkdir -p "$@"


.PHONY: .build/mariadb/VERSION
.build/mariadb/VERSION:
	docker run --rm --entrypoint=printenv marketplace.gcr.io/google/mariadb10@$(MARIADB_TAG) MARIADB_VERSION \
	  | awk -F'+' '{ print $$1 }' \
	  | awk -F':' '{ print $$2 }'


.build/mariadb/deployer: deployer/* \
                         chart/mariadb/* \
                         chart/mariadb/templates/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TRACK \
                         .build/var/RELEASE \
                         | .build/mariadb
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


.build/mariadb/mariadb: .build/var/REGISTRY \
                        .build/var/TRACK \
                        .build/var/RELEASE \
                        | .build/mariadb
	docker pull marketplace.gcr.io/google/mariadb10@$(MARIADB_TAG)
	docker tag marketplace.gcr.io/google/mariadb10@$(MARIADB_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/mariadb/mysqld-exporter: .build/var/REGISTRY \
                                .build/var/TRACK \
                                .build/var/RELEASE \
                                | .build/mariadb
	docker pull marketplace.gcr.io/google/mysql5:exporter
	docker tag marketplace.gcr.io/google/mysql5:exporter \
	    "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	@touch "$@"


.build/mariadb/prometheus-to-sd: .build/var/REGISTRY \
                                 .build/var/TRACK \
                                 .build/var/RELEASE \
                                 | .build/mariadb
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/mariadb/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/mariadb
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
