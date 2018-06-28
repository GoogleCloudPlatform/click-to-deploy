TAG ?= latest

# crd.Makefile provides targets to install Application CRD.
include ../vendor/marketplace-tools/crd.Makefile

# gcloud.Makefile provides default values for
# REGISTRY and NAMESPACE derived from local
# gcloud and kubectl environments.
include ../vendor/marketplace-tools/gcloud.Makefile

# marketplace.Makefile provides targets such as
# ".build/marketplace/deployer/envsubst" to build the base
# deployer images locally.
include ../vendor/marketplace-tools/marketplace.Makefile

# ubbagent.Makefile provides ".build/ubbagent/ubbagent"
# target to build the ubbagent image locally.
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined as followed.
include ../vendor/marketplace-tools/app.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/grafana/deployer:$(TAG)
NAME ?= grafana-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)", \
  "image.grafana": "$(REGISTRY)/grafana:$(TAG)" \
}

# Extend the target as defined in app.Makefile to
# include real dependencies.
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


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/grafana/grafana: .build/var/REGISTRY \
						.build/var/TAG \
						| .build/grafana
	docker pull grafana/grafana:5.1.2
	docker tag grafana/grafana:5.1.2 "$(REGISTRY):$(TAG)"
	docker push "$(REGISTRY):$(TAG)"
	@touch "$@"