include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= latest
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/rabbitmq/deployer:$(TAG)
NAME ?= rabbitmq-1
REPLICAS ?= 3
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)", \
  "REPLICAS": "$(REPLICAS)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/rabbitmq/deployer \
            .build/rabbitmq/rabbitmq


.build/rabbitmq: | .build
	mkdir -p "$@"


.build/rabbitmq/deployer: deployer/* \
                          manifest/* \
                          .build/marketplace/deployer/envsubst \
                          .build/var/APP_DEPLOYER_IMAGE \
                          .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/rabbitmq
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/rabbitmq" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/rabbitmq/rabbitmq: .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/rabbitmq
	docker pull launcher.gcr.io/google/rabbitmq3:3.7-debian9
	docker tag launcher.gcr.io/google/rabbitmq3:3.7-debian9 \
	    "$(REGISTRY)/rabbitmq:$(TAG)"
	docker push "$(REGISTRY)/rabbitmq:$(TAG)"
	@touch "$@"
