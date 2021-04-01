include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 1.0
SERVER_VERSION ?= 1.0.0

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/voucher/deployer:$(TAG)
NAME ?= voucher-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/voucher/tester:$(TAG)


app/build:: .build/voucher/deployer \
            .build/voucher/server \
            .build/voucher/tester

.build/voucher: | .build
	mkdir -p "$@"


.build/voucher/deployer: deployer/* \
                            manifest/* \
                            schema.yaml \
                            .build/var/APP_DEPLOYER_IMAGE \
                            .build/var/MARKETPLACE_TOOLS_TAG \
                            .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/voucher
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/voucher" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/voucher/server: .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/voucher
	docker pull gcr.io/binauthz-public/voucher:$(SERVER_VERSION)
	docker tag gcr.io/binauthz-public/voucher:$(SERVER_VERSION) "$(REGISTRY)/voucher:$(SERVER_VERSION)"
	docker push "$(REGISTRY)/voucher:$(SERVER_VERSION)"
	@touch "$@"


.build/voucher/tester: .build/var/TESTER_IMAGE \
                          $(shell find apptest -type f) \
                          | .build/voucher
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
