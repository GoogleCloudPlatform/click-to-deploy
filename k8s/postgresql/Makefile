include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 9.6
METRICS_EXPORTER_TAG ?= v0.5.1

SRCTAG ?= 9.6-kubernetes
IMAGE_POSTGRESQL ?= marketplace.gcr.io/google/postgresql9:$(SRCTAG)
IMAGE_POSTGRESQL_EXPORTER ?= marketplace.gcr.io/google/postgresql9:exporter

$(info ---- TAG = $(TAG))

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

ifdef EXPOSE_PUBLIC_SERVICE
  EXPOSE_PUBLIC_SERVICE_FIELD = , "postgresql.exposePublicService": "$(EXPOSE_PUBLIC_SERVICE)"
endif

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/postgresql/deployer:$(TAG)
NAME ?= postgresql-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(EXPOSE_PUBLIC_SERVICE_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/postgresql/tester:$(TAG)


app/build:: .build/postgresql/deployer \
            .build/postgresql/postgresql \
            .build/postgresql/exporter \
            .build/postgresql/prometheus-to-sd \
            .build/postgresql/tester


.build/postgresql: | .build
	mkdir -p "$@"


.build/postgresql/deployer: deployer/* \
                            chart/postgresql/* \
                            chart/postgresql/templates/* \
                            schema.yaml \
                            .build/var/APP_DEPLOYER_IMAGE \
                            .build/var/MARKETPLACE_TOOLS_TAG \
                            .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/postgresql
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/postgresql" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/postgresql/postgresql: .build/var/REGISTRY \
                              .build/var/TAG \
                              | .build/postgresql
	docker pull $(IMAGE_POSTGRESQL)
	docker tag $(IMAGE_POSTGRESQL) "$(REGISTRY)/postgresql:$(TAG)"
	docker push "$(REGISTRY)/postgresql:$(TAG)"
	@touch "$@"


.build/postgresql/exporter: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/postgresql
	docker pull $(IMAGE_POSTGRESQL_EXPORTER)
	docker tag $(IMAGE_POSTGRESQL_EXPORTER) "$(REGISTRY)/postgresql/exporter:$(TAG)"
	docker push "$(REGISTRY)/postgresql/exporter:$(TAG)"
	@touch "$@"


.build/postgresql/prometheus-to-sd: .build/var/REGISTRY \
                                    .build/var/TAG \
                                    | .build/postgresql
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/postgresql/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/postgresql/prometheus-to-sd:$(TAG)"
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
