include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 3.7
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

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_RABBITMQ_FIELD) \
  $(IMAGE_RABBITMQ_INIT_FIELD) \
  $(REPLICAS_FIELD) \
  $(RABBITMQ_ERLANG_COOKIE_FIELD) \
  $(RABBITMQ_DEFAULT_USER_FIELD) \
  $(RABBITMQ_DEFAULT_PASS_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/rabbitmq/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/rabbitmq/debian9  \
            .build/rabbitmq/deployer \
            .build/rabbitmq/rabbitmq \
            .build/rabbitmq/tester


.build/rabbitmq: | .build
	mkdir -p "$@"


.build/rabbitmq/debian9: .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/rabbitmq
	docker pull launcher.gcr.io/google/debian9
	docker tag launcher.gcr.io/google/debian9 "$(REGISTRY)/rabbitmq/debian9:$(TAG)"
	docker push "$(REGISTRY)/rabbitmq/debian9:$(TAG)"
	@touch "$@"


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
	docker pull launcher.gcr.io/google/rabbitmq3:$(TAG)
	docker tag launcher.gcr.io/google/rabbitmq3:$(TAG) \
	    "$(REGISTRY)/rabbitmq:$(TAG)"
	docker push "$(REGISTRY)/rabbitmq:$(TAG)"
	@touch "$@"

.build/rabbitmq/tester: .build/var/TESTER_IMAGE \
                        $(shell find apptest -type f) \
                        | .build/rabbitmq
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
