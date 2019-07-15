include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= rabbitmq-managed-updates

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/rabbitmq/VERSION` target to fill the RELEASE variable.
RABBITMQ_TAG ?= sha256:b93db2c98986ec1d985218ffc512292aa0f9c0059016b727817d4ec10c692c49
METRICS_EXPORTER_TAG ?= v0.5.1

TIMESTAMP := $(shell date +%s)
TRACK ?= 3.7
RELEASE ?= 3.7.13-$(TIMESTAMP)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef IMAGE_RABBITMQ_INIT
  IMAGE_RABBITMQ_INIT_FIELD = , "rabbitmq.initImage": "$(IMAGE_RABBITMQ_INIT)"
endif

ifdef REPLICAS
  REPLICAS_FIELD = , "rabbitmq.replicas": "$(REPLICAS)"
endif

ifdef RABBITMQ_ERLANG_COOKIE
  RABBITMQ_ERLANG_COOKIE_FIELD = , "rabbitmq.erlangCookie": "$(RABBITMQ_ERLANG_COOKIE)"
endif

ifdef RABBITMQ_DEFAULT_USER
  RABBITMQ_DEFAULT_USER_FIELD = , "rabbitmq.user": "$(RABBITMQ_DEFAULT_USER)"
endif

ifdef RABBITMQ_DEFAULT_PASS
  RABBITMQ_DEFAULT_PASS_FIELD = , "rabbitmq.password": "$(RABBITMQ_DEFAULT_PASS)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_RABBITMQ_INIT_FIELD) \
  $(REPLICAS_FIELD) \
  $(RABBITMQ_ERLANG_COOKIE_FIELD) \
  $(RABBITMQ_DEFAULT_USER_FIELD) \
  $(RABBITMQ_DEFAULT_PASS_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/rabbitmq/deployer \
            .build/rabbitmq/rabbitmq \
            .build/rabbitmq/debian9 \
            .build/rabbitmq/prometheus-to-sd \
            .build/rabbitmq/tester \
            .build/rabbitmq/VERSION


.build/rabbitmq: | .build
	mkdir -p "$@"


.PHONY: .build/rabbitmq/VERSION
.build/rabbitmq/VERSION:
	docker run --rm --entrypoint=printenv marketplace.gcr.io/google/rabbitmq3@$(RABBITMQ_TAG) RABBITMQ_VERSION


.build/rabbitmq/deployer: deployer/* \
                          chart/rabbitmq/* \
                          chart/rabbitmq/templates/* \
                          schema.yaml \
                          .build/var/APP_DEPLOYER_IMAGE \
                          .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                          .build/var/MARKETPLACE_TOOLS_TAG \
                          .build/var/REGISTRY \
                          .build/var/TRACK \
                          .build/var/RELEASE \
                          | .build/rabbitmq
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


.build/rabbitmq/rabbitmq: .build/var/REGISTRY \
                          .build/var/TRACK \
                          .build/var/RELEASE \
                          | .build/rabbitmq
	docker pull marketplace.gcr.io/google/rabbitmq3@$(RABBITMQ_TAG)
	docker tag marketplace.gcr.io/google/rabbitmq3@$(RABBITMQ_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/rabbitmq/debian9: .build/var/REGISTRY \
                         .build/var/TRACK \
                         .build/var/RELEASE \
                         | .build/rabbitmq
	docker pull marketplace.gcr.io/google/debian9:latest
	docker tag marketplace.gcr.io/google/debian9:latest \
	    "$(REGISTRY)/$(APP_ID)/debian9:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/debian9:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/debian9:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/debian9:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/debian9:$(RELEASE)"
	@touch "$@"


.build/rabbitmq/prometheus-to-sd: .build/var/REGISTRY \
                                  .build/var/TRACK \
                                  .build/var/RELEASE \
                                  | .build/rabbitmq
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/rabbitmq/tester: .build/var/TESTER_IMAGE \
                        $(shell find apptest -type f) \
                        | .build/rabbitmq
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
