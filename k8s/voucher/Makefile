include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 1.0

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/voucher/deployer:$(TAG)
NAME ?= voucher-1

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
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
	docker pull gcr.io/binauthz-public/voucher:$(TAG)
	docker tag gcr.io/binauthz-public/voucher:$(TAG) "$(REGISTRY)/voucher:$(TAG)"
	docker push "$(REGISTRY)/voucher:$(TAG)"
	@touch "$@"


.build/voucher/tester: .build/var/TESTER_IMAGE \
                          $(shell find apptest -type f) \
                          | .build/voucher
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
