include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

VERIFY_WAIT_TIMEOUT = 600

TAG ?= 7.6
METRICS_EXPORTER_TAG ?= v0.5.1

POSTGRESQL_SRCTAG ?= 9.6-kubernetes
IMAGE_SONARQUBE ?= marketplace.gcr.io/google/sonarqube7:$(TAG)
IMAGE_POSTGRESQL ?= marketplace.gcr.io/google/postgresql9:$(POSTGRESQL_SRCTAG)
IMAGE_POSTGRESQL_EXPORTER ?= marketplace.gcr.io/google/postgresql9:exporter

$(info ---- TAG = $(TAG))

ifdef DB_PASSWORD
  DB_PASSWORD_FIELD = , "postgresql.db.password": "$(DB_PASSWORD)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/sonarqube/deployer:$(TAG)
NAME ?= sonarqube-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(DB_PASSWORD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/sonarqube/tester:$(TAG)


app/build:: .build/sonarqube/deployer \
            .build/sonarqube/sonarqube \
            .build/sonarqube/postgresql \
            .build/sonarqube/postgresql-exporter \
            .build/sonarqube/prometheus-to-sd \
            .build/sonarqube/tester


.build/sonarqube: | .build
	mkdir -p "$@"


.build/sonarqube/deployer: deployer/* \
                           chart/sonarqube/* \
                           chart/sonarqube/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/sonarqube
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/sonarqube" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/sonarqube/sonarqube: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/sonarqube
	docker pull $(IMAGE_SONARQUBE)
	docker tag $(IMAGE_SONARQUBE) "$(REGISTRY)/sonarqube:$(TAG)"
	docker push "$(REGISTRY)/sonarqube:$(TAG)"
	@touch "$@"


.build/sonarqube/postgresql: .build/var/REGISTRY \
                             .build/var/TAG \
                             | .build/sonarqube
	docker pull $(IMAGE_POSTGRESQL)
	docker tag $(IMAGE_POSTGRESQL) "$(REGISTRY)/sonarqube/postgresql:$(TAG)"
	docker push "$(REGISTRY)/sonarqube/postgresql:$(TAG)"
	@touch "$@"


.build/sonarqube/postgresql-exporter: .build/var/REGISTRY \
                                      .build/var/TAG \
                                      | .build/sonarqube
	docker pull $(IMAGE_POSTGRESQL_EXPORTER)
	docker tag $(IMAGE_POSTGRESQL_EXPORTER) "$(REGISTRY)/sonarqube/postgresql-exporter:$(TAG)"
	docker push "$(REGISTRY)/sonarqube/postgresql-exporter:$(TAG)"
	@touch "$@"


.build/sonarqube/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   | .build/sonarqube
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/sonarqube/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/sonarqube/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/sonarqube/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/sonarqube
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
