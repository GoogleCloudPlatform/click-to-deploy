include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= beta
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/flink-operator/deployer:$(TAG)
NAME ?= flink-operator-1

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/flink-operator/tester:$(TAG)


app/build:: .build/flink-operator/deployer \
            .build/flink-operator/flink-operator \
            .build/flink-operator/tester


.build/flink-operator: | .build
	mkdir -p "$@"


.build/flink-operator/deployer: deployer/* \
                                manifest/* \
                                schema.yaml \
                                .build/var/APP_DEPLOYER_IMAGE \
                                .build/var/MARKETPLACE_TOOLS_TAG \
                                .build/var/REGISTRY \
                                .build/var/TAG \
                                | .build/flink-operator
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/flink-operator" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/flink-operator/tester: apptest/**/*
	$(call print_target, $@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


.build/flink-operator/flink-operator: .build/var/REGISTRY \
                                      .build/var/TAG \
                                      | .build/flink-operator
	$(call print_target, $@)
	docker pull gcr.io/flink-operator/flink-operator:latest
	docker tag gcr.io/flink-operator/flink-operator:latest "$(REGISTRY)/flink-operator:$(TAG)"
	docker push "$(REGISTRY)/flink-operator:$(TAG)"
	@touch "$@"
