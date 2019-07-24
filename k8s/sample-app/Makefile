include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= latest

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/sample-app/deployer:$(TAG)
NAME ?= sample-app-1

ifdef IMAGE_SAMPLE_APP
  IMAGE_SAMPLE_APP_FIELD = , "IMAGE_SAMPLE_APP": "$(IMAGE_SAMPLE_APP)"
endif

ifdef SAMPLE_APP_PARAMETER1
  SAMPLE_APP_PARAMETER1_FIELD = , "SAMPLE_APP_PARAMETER1": "$(SAMPLE_APP_PARAMETER1)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_SAMPLE_APP_FIELD) \
  $(SAMPLE_APP_PARAMETER1_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/sample-app/tester:$(TAG)


app/build:: .build/sample-app/deployer \
            .build/sample-app/sample-app \
            .build/sample-app/tester


.build/sample-app: | .build
	mkdir -p "$@"


.build/sample-app/deployer: deployer/* \
                       manifest/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
                       .build/var/MARKETPLACE_TOOLS_TAG \
                       .build/var/REGISTRY \
                       .build/var/TAG \
                       | .build/sample-app
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/sample-app" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/sample-app/sample-app: .build/var/REGISTRY \
                              .build/var/TAG \
                              | .build/sample-app

	docker pull marketplace.gcr.io/google/nginx1:$(TAG)
	docker tag marketplace.gcr.io/google/nginx1:$(TAG) \
	    "$(REGISTRY)/sample-app:$(TAG)"
	docker push "$(REGISTRY)/sample-app:$(TAG)"


.build/sample-app/tester: .build/var/TESTER_IMAGE \
                          $(shell find apptest -type f) \
                          | .build/sample-app
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
