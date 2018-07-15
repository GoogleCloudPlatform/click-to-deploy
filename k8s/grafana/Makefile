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
  IMAGE_GRAFANA_FIELD = , "image.grafana": "$(IMAGE_GRAFANA)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_GRAFANA_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/grafana/deployer \
            .build/grafana/grafana


.build/grafana: | .build
	mkdir -p "$@"


.build/grafana/deployer: deployer/* \
                         grafana/* \
                         schema.yaml \
                         .build/marketplace/deployer/helm \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/grafana
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)" \
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
	docker tag launcher.gcr.io/google/grafana5:$(TAG) "$(REGISTRY):$(TAG)"
	docker push "$(REGISTRY):$(TAG)"
	@touch "$@"
