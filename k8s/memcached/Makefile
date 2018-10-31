include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 1.5
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/memcached/deployer:$(TAG)
NAME ?= memcached-1
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/memcached/deployer \
	    .build/memcached/memcached


.build/memcached: | .build
	mkdir -p "$@"


.build/memcached/deployer: deployer/* \
                           manifest/* \
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
	docker pull launcher.gcr.io/google/memcached1:$(TAG)
	docker tag launcher.gcr.io/google/memcached1:$(TAG) \
	    "$(REGISTRY)/memcached:$(TAG)"
	docker push "$(REGISTRY)/memcached:$(TAG)"
	@touch "$@"
