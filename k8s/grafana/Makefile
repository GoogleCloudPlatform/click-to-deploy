include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 5.3
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/grafana/deployer:$(TAG)
NAME ?= grafana-1

ifdef IMAGE_GRAFANA
  IMAGE_GRAFANA_FIELD = , "grafana.image": "$(IMAGE_GRAFANA)"
endif

ifdef IMAGE_GRAFANA_INIT
  IMAGE_GRAFANA_INIT_FIELD = , "grafana.initImage": "$(IMAGE_GRAFANA_INIT)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_GRAFANA_FIELD) \
  $(IMAGE_GRAFANA_INIT_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/grafana/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/grafana/debian9 \
            .build/grafana/deployer \
            .build/grafana/grafana \
            .build/grafana/tester


.build/grafana: | .build
	mkdir -p "$@"


.build/grafana/deployer: deployer/* \
                         chart/grafana/* \
                         chart/grafana/templates/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/grafana
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/grafana" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
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


.build/grafana/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/grafana
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
