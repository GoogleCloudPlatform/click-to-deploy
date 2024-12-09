#
# Used with app_v2 Makefile for deployer schema v2.
#

ifndef __C2D_DEPLOYER_MAKEFILE__

__C2D_DEPLOYER_MAKEFILE__:= included

##### Check required variables #####


ifndef CHART_NAME
$(error CHART_NAME must be defined)
endif

$(info ---- CHART_NAME = $(CHART_NAME))

ifndef APP_ID
$(error APP_ID must be defined)
endif

$(info ---- APP_ID = $(APP_ID))

ifndef image-$(CHART_NAME)
$(error image-$(CHART_NAME) must be defined)
endif

$(info ---- image-$(CHART_NAME) = $(image-$(CHART_NAME)))


##### Common variables #####

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TRACK)
APP_TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TRACK)


include ../app_v2.Makefile


$(info ---- TRACK = $(TRACK))
$(info ---- RELEASE = $(RELEASE))


##### Helper targets #####

.build/$(CHART_NAME): | .build
	mkdir -p "$@"


app/build:: .build/$(CHART_NAME)/VERSION \
            .build/$(CHART_NAME)/$(CHART_NAME) \
            .build/$(CHART_NAME)/images \
            .build/$(CHART_NAME)/deployer


.build/$(CHART_NAME)/deployer: deployer/* \
                               chart/$(CHART_NAME)/* \
                               chart/$(CHART_NAME)/templates/* \
                               schema.yaml \
                               .build/var/APP_DEPLOYER_IMAGE \
                               .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                               .build/var/MARKETPLACE_TOOLS_TAG \
                               .build/var/REGISTRY \
                               .build/var/TRACK \
                               .build/var/RELEASE \
                               | .build/$(CHART_NAME)
	$(call print_target,$@)

	docker buildx create --name deployer-builder --use
	docker buildx inspect deployer-builder --bootstrap
	docker buildx build \
		--push \
		--annotation="index,manifest:cloudmarketplace.googleapis.com/service=$(SERVICE_NAME)" \
		--build-arg REGISTRY="$(REGISTRY)/$(APP_ID)" \
		--build-arg TAG="$(RELEASE)" \
		--build-arg CHART_NAME="$(CHART_NAME)" \
		--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
		--tag "$(APP_DEPLOYER_IMAGE)" \
		--tag "$(APP_DEPLOYER_IMAGE_TRACK_TAG)" \
		-f deployer/Dockerfile \
		.
	@docker buildx rm deployer-builder
	@touch "$@"


.build/$(CHART_NAME)/$(CHART_NAME): .build/var/REGISTRY \
                                    .build/var/TRACK \
                                    .build/var/RELEASE \
                                    | .build/$(CHART_NAME)
	$(call print_target,$@)

	crane copy "$(image-$(CHART_NAME))" "$(REGISTRY)/$(APP_ID):$(TRACK)"
	crane copy "$(image-$(CHART_NAME))" "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


# map every element of ADDITIONAL_IMAGES list
# from [image-name] to .build/$(CHART_NAME)/[image-name] format
IMAGE_TARGETS_LIST = $(patsubst %,.build/$(CHART_NAME)/%,$(ADDITIONAL_IMAGES))
.build/$(CHART_NAME)/images: $(IMAGE_TARGETS_LIST)

# extract image name from rule with .build/$(CHART_NAME)/%
# and use % match as $* in recipe
$(IMAGE_TARGETS_LIST): .build/$(CHART_NAME)/%: .build/var/REGISTRY \
                                               .build/var/TRACK \
                                               .build/var/RELEASE \
                                               | .build/$(CHART_NAME)
	$(call print_target,$*)

	crane copy "$(image-$*)" "$(REGISTRY)/$(APP_ID)/$*:$(TRACK)"
	crane copy "$(image-$*)" "$(REGISTRY)/$(APP_ID)/$*:$(RELEASE)"
	@touch "$@"


.build/$(CHART_NAME)/tester: .build/var/APP_TESTER_IMAGE \
                             $(shell find apptest -type f) \
                             | .build/$(CHART_NAME)
	$(call print_target,$@)

	docker buildx create --name tester-builder --use
	docker buildx inspect tester-builder --bootstrap

	cd apptest/tester \
		&& docker buildx build \
				--push \
				--annotation="index,manifest:cloudmarketplace.googleapis.com/service=$(SERVICE_NAME)" \
				--tag "$(APP_TESTER_IMAGE)" .

	@docker buildx rm tester-builder
	@touch "$@"


########### Main  targets ###########


.PHONY: .build/$(CHART_NAME)/VERSION
.build/$(CHART_NAME)/VERSION:
	$(call print_target,$@)
	@echo "$(C2D_CONTAINER_RELEASE)" | grep -qE "^$(TRACK)\.[0-9]+(\.[0-9]+)?$$" || \
	( echo "C2D_RELEASE doesn't start with TRACK or doesn't match TRACK exactly"; exit 1 )


endif
