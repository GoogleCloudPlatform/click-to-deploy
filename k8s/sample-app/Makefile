include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= latest
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/nginx/deployer:$(TAG)
NAME ?= sample-app

ifdef IMAGE_SAMPLE_APP
  IMAGE_SAMPLE_APP = , "IMAGE_SAMPLE_APP": "$(IMAGE_SAMPLE_APP)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_SAMPLE_APP) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/nginx/debian9  \
            .build/nginx/deployer \
            .build/nginx/nginx


.build/nginx: | .build
	mkdir -p "$@"


.build/nginx/debian9: .build/var/REGISTRY \
                      .build/var/TAG \
                      | .build/nginx
	docker pull launcher.gcr.io/google/debian9
	docker tag launcher.gcr.io/google/debian9 "$(REGISTRY)/nginx/debian9:$(TAG)"
	docker push "$(REGISTRY)/nginx/debian9:$(TAG)"
	@touch "$@"


.build/nginx/deployer: deployer/* \
                       manifest/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
                       .build/var/REGISTRY \
                       .build/var/TAG \
                       | .build/nginx
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/nginx" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/nginx/nginx: .build/var/REGISTRY \
                    .build/var/TAG \
                    | .build/nginx
	docker pull launcher.gcr.io/google/nginx1baaaad:$(TAG)
	docker tag launcher.gcr.io/google/nginx1baaaad:$(TAG) \
	    "$(REGISTRY)/nginx:$(TAG)"
	docker push "$(REGISTRY)/nginx:$(TAG)"
	@touch "$@"

