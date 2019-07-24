include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 1.5
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/memcached/deployer:$(TAG)
NAME ?= memcached-1

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/memcached/tester:$(TAG)


app/build:: .build/memcached/deployer \
            .build/memcached/memcached \
            .build/memcached/prometheus-to-sd \
            .build/memcached/tester


.build/memcached: | .build
	mkdir -p "$@"


.build/memcached/deployer: deployer/* \
                           chart/memcached/* \
                           chart/memcached/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/memcached
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/memcached" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/memcached/memcached: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/memcached
	docker pull marketplace.gcr.io/google/memcached1:$(TAG)
	docker tag marketplace.gcr.io/google/memcached1:$(TAG) \
	    "$(REGISTRY)/memcached:$(TAG)"
	docker push "$(REGISTRY)/memcached:$(TAG)"
	@touch "$@"


.build/memcached/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   | .build/memcached
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/memcached/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/memcached/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/memcached/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/memcached
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
