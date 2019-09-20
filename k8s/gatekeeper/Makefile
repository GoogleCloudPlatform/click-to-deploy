TAG ?= 3.0
SOURCE_REGISTRY ?= gcr.io/gatekeeper-marketplace

# Convenience makefiles.
include ../gcloud.Makefile
include ../var.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/gatekeeper/deployer:$(TAG)
GATEKEEPER_IMAGE ?= $(SOURCE_REGISTRY)/gatekeeper:$(TAG)
NAME ?= gatekeeper
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "imageGatekeeper": "$(GATEKEEPER_IMAGE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/gatekeeper/deployer/tester:$(TAG)
APP_TEST_PARAMETERS ?= { \
  "imageTester": "$(TESTER_IMAGE)" \
}

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app.Makefile


# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/gatekeeper/deployer \
            .build/gatekeeper/tester \
            .build/gatekeeper/gatekeeper

.build/app: | .build
	mkdir -p "$@"


# Overwriting parent to change gcr path -- remove when done using staging
.PHONY: .build/app/dev
.build/app/dev: .build/var/MARKETPLACE_TOOLS_TAG \
              | .build/app
	@docker run \
	    "gcr.io/cloud-marketplace-staging/marketplace-k8s-app-tools/k8s/dev:$(MARKETPLACE_TOOLS_TAG)" \
	    cat /scripts/dev > "/tmp/dev"
	@mv "/tmp/dev" "$@"
	@chmod a+x "$@"

.build/gatekeeper: | .build
	mkdir -p "$@"

.build/gatekeeper/deployer: .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           apptest/deployer/* \
                           apptest/deployer/manifest/* \
                           deployer/* \
                           manifest/* \
                           schema.yaml \
                           licenses \
                           | .build/gatekeeper
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/gatekeeper" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/gatekeeper/tester: .build/var/TESTER_IMAGE
	$(call print_target, $@)
	docker pull cosmintitei/bash-curl
	docker tag cosmintitei/bash-curl "$(TESTER_IMAGE)"
	docker push "$(TESTER_IMAGE)"
	@touch "$@"

.build/gatekeeper/gatekeeper: .build/var/REGISTRY \
                              .build/var/TAG \
                            | .build/gatekeeper
	$(call print_target, $@)
	docker push "$(GATEKEEPER_IMAGE)"
	@touch "$@"

# concatenate all licenses together
licenses:
	$(call print_target, $@)
	rm -rf .build/licenses
	mkdir -p .build/licenses
	cp ../../LICENSE .build/licenses/.
	echo >> .build/licenses/LICENSE
	echo '-----' >> .build/licenses/LICENSE
	echo >> .build/licenses/LICENSE
	cat licenses_for_manifest/LICENSE >> .build/licenses/LICENSE
