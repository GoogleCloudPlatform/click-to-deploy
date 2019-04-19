include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


SOLUTION_ID ?= mariadb10
TAG ?= 10.3
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/mariadb/deployer:$(TAG)
NAME ?= mariadb

ifdef IMAGE_MARIADB
  IMAGE_MARIADB_FIELD = , "mariadb.image": "$(IMAGE_MARIADB)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_MARIADB_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/mariadb/tester:$(TAG)

app/build:: .build/mariadb/deployer \
            .build/mariadb/mariadb \
            .build/mariadb/tester


.build/mariadb: | .build
	mkdir -p "$@"


.build/mariadb/deployer: deployer/* \
                         chart/mariadb/* \
                         chart/mariadb/templates/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/mariadb
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/mariadb" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/mariadb/mariadb: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/mariadb

	docker pull marketplace.gcr.io/google/$(SOLUTION_ID):$(TAG)
	docker tag marketplace.gcr.io/google/$(SOLUTION_ID):$(TAG) \
	    "$(REGISTRY)/mariadb:$(TAG)"
	docker push "$(REGISTRY)/mariadb:$(TAG)"
	@touch "$@"

.build/mariadb/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/mariadb
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
