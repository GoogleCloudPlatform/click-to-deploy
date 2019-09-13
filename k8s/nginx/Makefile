include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

APP_ID ?= nginx-managed-updates

# The digest should be updated automatically, or tag <major>.<minor>.<path/build>
# should be available on GCP Marketplace.
# Use `.build/nginx/VERSION` target to fill the RELEASE variable.
NGINX_TAG ?= sha256:c797f96cf1529764cf8674a757d4f85e20f410912380ed446f3f032f5edb29a3
METRICS_EXPORTER_TAG ?= v0.5.1

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
TRACK ?= 1.15
RELEASE ?= 1.15.12-$(BUILD_ID)

$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)

NAME ?= $(APP_ID)-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": $(METRICS_EXPORTER_ENABLED)
endif

ifdef IMAGE_NGINX_INIT
  IMAGE_NGINX_INIT_FIELD = , "nginx.initImage": "$(IMAGE_NGINX_INIT)"
endif

ifdef PUBLIC_IP_AVAILABLE
  PUBLIC_IP_AVAILABLE_FIELD = , "publicIp.available": $(PUBLIC_IP_AVAILABLE)
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_NGINX_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(PUBLIC_IP_AVAILABLE_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

app/build:: .build/nginx/deployer \
            .build/nginx/nginx \
            .build/nginx/debian9 \
            .build/nginx/prometheus-to-sd \
            .build/nginx/tester \
            .build/nginx/VERSION


.build/nginx: | .build
	mkdir -p "$@"


.PHONY: .build/nginx/VERSION
.build/nginx/VERSION:
	docker run --rm --entrypoint=printenv marketplace.gcr.io/google/nginx1@$(NGINX_TAG) NGINX_VERSION | awk -F* '{ print $$1 }'


.build/nginx/deployer: deployer/* \
                       chart/nginx/* \
                       chart/nginx/templates/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
                       .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                       .build/var/MARKETPLACE_TOOLS_TAG \
                       .build/var/REGISTRY \
                       .build/var/TRACK \
                       .build/var/RELEASE \
                       | .build/nginx
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


.build/nginx/nginx: .build/var/REGISTRY \
                    .build/var/TRACK \
                    .build/var/RELEASE \
                    | .build/nginx
	docker pull marketplace.gcr.io/google/nginx1@$(NGINX_TAG)
	docker tag marketplace.gcr.io/google/nginx1@$(NGINX_TAG) \
	    "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/nginx/debian9: .build/var/REGISTRY \
                      .build/var/TRACK \
                      .build/var/RELEASE \
                      | .build/nginx
	docker pull marketplace.gcr.io/google/debian9:latest
	docker tag marketplace.gcr.io/google/debian9:latest \
	    "$(REGISTRY)/$(APP_ID)/debian9:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/debian9:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/debian9:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/debian9:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/debian9:$(RELEASE)"
	@touch "$@"


.build/nginx/prometheus-to-sd: .build/var/REGISTRY \
                               .build/var/TRACK \
                               .build/var/RELEASE \
                               | .build/nginx
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)" \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/nginx/tester: .build/var/TESTER_IMAGE \
                     $(shell find apptest -type f) \
                     | .build/nginx
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
