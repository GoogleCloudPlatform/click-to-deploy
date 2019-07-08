include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= postgresql-managed-updates

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/postgresql/VERSION` target to fill the RELEASE variable.
POSTGRESQL_TAG ?= sha256:9aa2e8b294818b834ecf5bb83ce84bb5741038aef81650d0a6c0ddea0a0df897
METRICS_EXPORTER_TAG ?= v0.5.1

TIMESTAMP := $(shell date +%s)
TRACK ?= 9.6
RELEASE ?= 9.6.10-build.$(TIMESTAMP)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

ifdef EXPOSE_PUBLIC_SERVICE
  EXPOSE_PUBLIC_SERVICE_FIELD = , "postgresql.exposePublicService": "$(EXPOSE_PUBLIC_SERVICE)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(EXPOSE_PUBLIC_SERVICE_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/postgresql/deployer \
            .build/postgresql/postgresql \
            .build/postgresql/exporter \
            .build/postgresql/prometheus-to-sd \
            .build/postgresql/tester \
            .build/postgresql/VERSION


.build/postgresql: | .build
	mkdir -p "$@"


.PHONY: .build/postgresql/VERSION
.build/postgresql/VERSION:
	docker run --rm marketplace.gcr.io/google/postgresql9@$(POSTGRESQL_TAG) postgres -V 2>/dev/null | tail -n 1 | awk '{print $$NF}'


.build/postgresql/deployer: deployer/* \
                            chart/postgresql/* \
                            chart/postgresql/templates/* \
                            schema.yaml \
                            .build/var/APP_DEPLOYER_IMAGE \
                            .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                            .build/var/MARKETPLACE_TOOLS_TAG \
                            .build/var/REGISTRY \
                            .build/var/TRACK \
                            .build/var/RELEASE \
                            | .build/postgresql
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


.build/postgresql/postgresql: .build/var/REGISTRY \
                              .build/var/TRACK \
                              .build/var/RELEASE \
                              | .build/postgresql
	docker pull marketplace.gcr.io/google/postgresql9@$(POSTGRESQL_TAG)
	docker tag marketplace.gcr.io/google/postgresql9@$(POSTGRESQL_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/postgresql/exporter: .build/var/REGISTRY \
                            .build/var/TRACK \
                            .build/var/RELEASE \
                            | .build/postgresql
	docker pull marketplace.gcr.io/google/postgresql9:exporter
	docker tag marketplace.gcr.io/google/postgresql9:exporter \
	    "$(REGISTRY)/$(APP_ID)/exporter:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/exporter:$(TRACK)" "$(REGISTRY)/$(APP_ID)/exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/exporter:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/exporter:$(RELEASE)"
	@touch "$@"


.build/postgresql/prometheus-to-sd: .build/var/REGISTRY \
                                    .build/var/TRACK \
                                    .build/var/RELEASE \
                                    | .build/postgresql
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/postgresql/tester: .build/var/TESTER_IMAGE \
                          $(shell find apptest -type f) \
                          | .build/postgresql
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


show-config:
	@psqlpass=$$(kubectl get secret/$(NAME)-secret -ojsonpath={.data.password} | base64 -d);\
	psqladdr=$$(kubectl get services/$(NAME)-postgresql-svc | awk '/^$(NAME)-postgresql/ {print $$4}');\
	psqluser=postgres;\
	echo;\
	echo -en "username: $$psqluser\n";\
	echo -en "password: $$psqlpass\n";\
	echo -en "address:  $$psqladdr\n";\
	echo;\
	echo "command:";\
	echo "PGPASSWORD=$$psqlpass psql sslmode=require -U$$psqluser -h $$psqladdr";\
	echo
