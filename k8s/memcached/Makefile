include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

DATE_VERSION := $(shell date --utc +%Y%m%d%H%M%S)

TAG ?= 1.5

RELEASE_TAG ?= $(TAG).$(DATE_VERSION)
TRACK_TAG ?= $(shell echo $(RELEASE_TAG) | cut -d . -f 1,2)

$(info ---- TAG = $(TAG))
$(info ---- RELEASE_TAG = $(RELEASE_TAG))
$(info ---- TRACK_TAG = $(TRACK_TAG))

APP_DEPLOYER_IMAGE_PREFIX ?= $(REGISTRY)/memcached/deployer
APP_DEPLOYER_IMAGE ?= $(APP_DEPLOYER_IMAGE_PREFIX):$(RELEASE_TAG)

NAME ?= memcached-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

TESTER_IMAGE_PREFIX ?= $(REGISTRY)/memcached/tester
TESTER_IMAGE ?= $(TESTER_IMAGE_PREFIX):$(RELEASE_TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


# Tags a docker image with a new tag and pushes the image with the new tag
define docker_tag_and_push
  docker tag $(1) $(2)
  docker push $(2)
endef


print_version:
	echo RELEASE_VERSION IS $(RELEASE_TAG)


app/build:: .build/memcached/deployer \
            .build/memcached/memcached \
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
	    --build-arg TAG="$(RELEASE_TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_PREFIX):$(TRACK_TAG)"
	$(call docker_tag_and_push,"$(APP_DEPLOYER_IMAGE)","$(APP_DEPLOYER_IMAGE_PREFIX):$(TRACK_TAG)")
	@touch "$@"


.build/memcached/memcached: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/memcached
	docker pull marketplace.gcr.io/google/memcached1:$(TAG)
	$(call docker_tag_and_push,"marketplace.gcr.io/google/memcached1:$(TAG)","$(REGISTRY)/memcached:$(RELEASE_TAG)")
	$(call docker_tag_and_push,"marketplace.gcr.io/google/memcached1:$(TAG)","$(REGISTRY)/memcached:$(TRACK_TAG)")
	@touch "$@"


.build/memcached/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/memcached
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	$(call docker_tag_and_push,"$(TESTER_IMAGE)","$(TESTER_IMAGE_PREFIX):$(TRACK_TAG)")
	@touch "$@"
