include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 1.15
METRICS_EXPORTER_TAG ?= v0.5.1
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/nginx/deployer:$(TAG)
NAME ?= nginx-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

ifdef IMAGE_NGINX
  IMAGE_NGINX_FIELD = , "nginx.image": "$(IMAGE_NGINX)"
endif

ifdef IMAGE_NGINX_INIT
  IMAGE_NGINX_INIT_FIELD = , "nginx.initImage": "$(IMAGE_NGINX_INIT)"
endif

ifdef PUBLIC_IP_AVAILABLE
  PUBLIC_IP_AVAILABLE_FIELD = , "publicIp.available": "$(PUBLIC_IP_AVAILABLE)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_NGINX_FIELD) \
  $(IMAGE_NGINX_INIT_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(PUBLIC_IP_AVAILABLE_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/nginx/tester:$(TAG)


app/build:: .build/nginx/debian9  \
            .build/nginx/deployer \
            .build/nginx/nginx \
            .build/nginx/prometheus-to-sd \
            .build/nginx/tester


.build/nginx: | .build
	mkdir -p "$@"


.build/nginx/debian9: .build/var/REGISTRY \
                      .build/var/TAG \
                      | .build/nginx
	docker pull marketplace.gcr.io/google/debian9
	docker tag marketplace.gcr.io/google/debian9 "$(REGISTRY)/nginx/debian9:$(TAG)"
	docker push "$(REGISTRY)/nginx/debian9:$(TAG)"
	@touch "$@"


.build/nginx/deployer: deployer/* \
                       chart/nginx/* \
                       chart/nginx/templates/* \
                       schema.yaml \
                       .build/var/APP_DEPLOYER_IMAGE \
                       .build/var/MARKETPLACE_TOOLS_TAG \
                       .build/var/REGISTRY \
                       .build/var/TAG \
                       | .build/nginx
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/nginx" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/nginx/nginx: .build/var/REGISTRY \
                    .build/var/TAG \
                    | .build/nginx
	docker pull marketplace.gcr.io/google/nginx1:$(TAG)
	docker tag marketplace.gcr.io/google/nginx1:$(TAG) \
	    "$(REGISTRY)/nginx:$(TAG)"
	docker push "$(REGISTRY)/nginx:$(TAG)"
	@touch "$@"

.build/nginx/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   | .build/nginx
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/nginx/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/nginx/prometheus-to-sd:$(TAG)"
	@touch "$@"

.build/nginx/tester: .build/var/TESTER_IMAGE \
                     $(shell find apptest -type f) \
                     | .build/nginx
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
