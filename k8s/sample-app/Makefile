include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= latest
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/sample-app/deployer:$(TAG)
NAME ?= sample-app

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
APP_TEST_PARAMETERS ?= {}


app/build:: .build/sample-app/debian9  \
            .build/sample-app/deployer \
            .build/sample-app/sample-app


.build/sample-app: | .build
	mkdir -p "$@"


.build/sample-app/debian9: .build/var/REGISTRY \
                      .build/var/TAG \
                      | .build/sample-app
	docker pull launcher.gcr.io/google/debian9
	docker tag launcher.gcr.io/google/debian9 "$(REGISTRY)/sample-app/debian9:$(TAG)"
	docker push "$(REGISTRY)/sample-app/debian9:$(TAG)"
	@touch "$@"


.build/sample-app/deployer: deployer/* \
                       manifest/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
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
	docker pull launcher.gcr.io/google/nginx1:$(TAG)
	docker tag launcher.gcr.io/google/nginx1:$(TAG) \
	    "$(REGISTRY)/sample-app:$(TAG)"
	docker push "$(REGISTRY)/sample-app:$(TAG)"
	@touch "$@"
