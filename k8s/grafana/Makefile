include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile

TAG ?= 5.1
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/grafana/deployer:$(TAG)
NAME ?= grafana-1

ifdef IMAGE_GRAFANA
  IMAGE_GRAFANA_FIELD = , "IMAGE_GRAFANA": "$(IMAGE_GRAFANA)"
endif

ifdef IMAGE_GRAFANA_INIT
  IMAGE_GRAFANA_INIT_FIELD = , "IMAGE_GRAFANA_INIT": "$(IMAGE_GRAFANA_INIT)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_GRAFANA_FIELD) \
  $(IMAGE_GRAFANA_INIT_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/grafana/deployer \
            .build/grafana/grafana \
            .build/grafana/debian9


.build/grafana: | .build
	mkdir -p "$@"


.build/grafana/deployer: deployer/* \
                         manifest/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/grafana
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/grafana" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/grafana/grafana: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/grafana
	docker pull launcher.gcr.io/google/grafana5:$(TAG)
	docker tag launcher.gcr.io/google/grafana5:$(TAG) "$(REGISTRY)/grafana:$(TAG)"
	docker push "$(REGISTRY)/grafana:$(TAG)"
	@touch "$@"


.build/grafana/debian9: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/grafana
	docker pull launcher.gcr.io/google/debian9
	docker tag launcher.gcr.io/google/debian9 "$(REGISTRY)/grafana/debian9:$(TAG)"
	docker push "$(REGISTRY)/grafana/debian9:$(TAG)"
	@touch "$@"
