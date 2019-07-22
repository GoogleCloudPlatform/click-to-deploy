include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 3.7
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/rabbitmq/deployer:$(TAG)
NAME ?= rabbitmq-1

ifdef IMAGE_RABBITMQ
  IMAGE_RABBITMQ_FIELD = , "rabbitmq.image": "$(IMAGE_RABBITMQ)"
endif

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
  $(IMAGE_RABBITMQ_FIELD) \
  $(IMAGE_RABBITMQ_INIT_FIELD) \
  $(REPLICAS_FIELD) \
  $(RABBITMQ_ERLANG_COOKIE_FIELD) \
  $(RABBITMQ_DEFAULT_USER_FIELD) \
  $(RABBITMQ_DEFAULT_PASS_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/rabbitmq/tester:$(TAG)


app/build:: .build/rabbitmq/deployer \
            .build/rabbitmq/rabbitmq \
            .build/rabbitmq/debian9 \
            .build/rabbitmq/prometheus-to-sd \
            .build/rabbitmq/tester


.build/rabbitmq: | .build
	mkdir -p "$@"


.build/rabbitmq/deployer: deployer/* \
                          chart/rabbitmq/* \
                          chart/rabbitmq/templates/* \
                          schema.yaml \
                          .build/var/APP_DEPLOYER_IMAGE \
                          .build/var/MARKETPLACE_TOOLS_TAG \
                          .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/rabbitmq
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/rabbitmq" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/rabbitmq/rabbitmq: .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/rabbitmq
	docker pull marketplace.gcr.io/google/rabbitmq3:$(TAG)
	docker tag marketplace.gcr.io/google/rabbitmq3:$(TAG) \
	    "$(REGISTRY)/rabbitmq:$(TAG)"
	docker push "$(REGISTRY)/rabbitmq:$(TAG)"
	@touch "$@"


.build/rabbitmq/debian9: .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/rabbitmq
	docker pull marketplace.gcr.io/google/debian9:latest
	docker tag marketplace.gcr.io/google/debian9:latest \
	    "$(REGISTRY)/rabbitmq/debian9:$(TAG)"
	docker push "$(REGISTRY)/rabbitmq/debian9:$(TAG)"
	@touch "$@"


.build/rabbitmq/prometheus-to-sd: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/rabbitmq
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/rabbitmq/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/rabbitmq/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/rabbitmq/tester: .build/var/TESTER_IMAGE \
                        $(shell find apptest -type f) \
                        | .build/rabbitmq
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
