include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= mariadb-managed-updates

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/mariadb/VERSION` target to fill the RELEASE variable.
MARIADB_TAG ?= sha256:edc02d0c232098d9882eed8cacfdde63deb7be631894a9323d9471990890b3df

TIMESTAMP := $(shell date +%s)
TRACK ?= 10.3
RELEASE ?= 10.3.15-build.$(TIMESTAMP)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/mariadb/deployer \
            .build/mariadb/mariadb \
            .build/mariadb/tester \
            .build/mariadb/VERSION


.build/mariadb: | .build
	mkdir -p "$@"


.PHONY: .build/mariadb/VERSION
.build/mariadb/VERSION:
	docker run --rm --entrypoint=printenv marketplace.gcr.io/google/mariadb10@$(MARIADB_TAG) MARIADB_VERSION \
	  | awk -F'+' '{ print $$1 }' \
	  | awk -F':' '{ print $$2 }'


.build/mariadb/deployer: deployer/* \
                         chart/mariadb/* \
                         chart/mariadb/templates/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TRACK \
                         .build/var/RELEASE \
                         | .build/mariadb
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/$(APP_ID)" \
	    --build-arg TAG="$(RELEASE)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker tag "$(APP_DEPLOYER_IMAGE)" "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/mariadb/mariadb: .build/var/REGISTRY \
                        .build/var/TRACK \
                        .build/var/RELEASE \
                        | .build/mariadb

	docker pull marketplace.gcr.io/google/mariadb10@$(MARIADB_TAG)
	docker tag marketplace.gcr.io/google/mariadb10@$(MARIADB_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"

.build/mariadb/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/mariadb
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
