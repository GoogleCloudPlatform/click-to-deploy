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

SHELL := /bin/bash

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

app/build:: .build/setup_crane \
						.build/$(CHART_NAME)/VERSION \
            .build/$(CHART_NAME)/$(CHART_NAME) \
            .build/$(CHART_NAME)/images \
            .build/$(CHART_NAME)/deployer

CRANE_BIN ?=
CRANE_AUTOINSTALL := false

ifeq ($(CRANE_BIN),)
	CRANE_BIN := /usr/local/bin/crane
	CRANE_AUTOINSTALL := true
else
	CRANE_AUTOINSTALL := false
endif

.build/setup_crane:
	@echo "Using Crane Bin at: $(CRANE_BIN)"
	@echo "Install Crane? $(CRANE_AUTOINSTALL)"

	@if ! command -v crane &>/dev/null && "$(CRANE_AUTOINSTALL)" == "true"; then \
		set -x; \
	  VERSION=v0.20.2; \
	  OS=Linux; \
	  ARCH=x86_64; \
	  echo "Downloading crane version $$VERSION..."; \
	  curl -v -L -o go-containerregistry.tar.gz "https://github.com/google/go-containerregistry/releases/download/$$VERSION/go-containerregistry_$${OS}_$${ARCH}.tar.gz" \
			&& tar -zxvf go-containerregistry.tar.gz crane \
			&& mv crane /usr/local/bin/crane \
			&& chmod 755 /usr/local/bin/crane \
			&& chmod +x /usr/local/bin/crane \
			&& rm go-containerregistry.tar.gz \
			&& echo "crane successfully installed"; \
	else \
	  echo "crane is already installed"; \
	fi; \
	chmod +x "$(CRANE_BIN)"; \
	"$(CRANE_BIN)" version


.build/$(CHART_NAME)/deployer: .build/setup_crane \
															 deployer/* \
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

	DEPLOYER_BUILDER="deployer-builder-$$(openssl rand -base64 12 | tr -dc 'a-z0-9' | head -c 8)"; \
		docker buildx create --name "$$DEPLOYER_BUILDER" --use \
		&& docker buildx inspect "$$DEPLOYER_BUILDER" --bootstrap \
		&& docker buildx build \
			--push \
			--annotation="index,manifest:com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME)" \
			--build-arg REGISTRY="$(REGISTRY)/$(APP_ID)" \
			--build-arg TAG="$(RELEASE)" \
			--build-arg CHART_NAME="$(CHART_NAME)" \
			--build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
			--tag "$(APP_DEPLOYER_IMAGE)" \
			--tag "$(APP_DEPLOYER_IMAGE_TRACK_TAG)" \
			-f deployer/Dockerfile \
			. \
		&& docker buildx rm "$$DEPLOYER_BUILDER"
	@touch "$@"


.build/$(CHART_NAME)/$(CHART_NAME): .build/setup_crane \
																		.build/var/REGISTRY \
                                    .build/var/TRACK \
                                    .build/var/RELEASE \
                                    | .build/$(CHART_NAME)
	$(call print_target,$@)

	"$(CRANE_BIN)" copy "$(image-$(CHART_NAME))" "$(REGISTRY)/$(APP_ID):$(TRACK)"
	"$(CRANE_BIN)" copy "$(image-$(CHART_NAME))" "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


# map every element of ADDITIONAL_IMAGES list
# from [image-name] to .build/$(CHART_NAME)/[image-name] format
IMAGE_TARGETS_LIST = $(patsubst %,.build/$(CHART_NAME)/%,$(ADDITIONAL_IMAGES))
.build/$(CHART_NAME)/images: .build/setup_crane \
														 $(IMAGE_TARGETS_LIST)

# extract image name from rule with .build/$(CHART_NAME)/%
# and use % match as $* in recipe
$(IMAGE_TARGETS_LIST): .build/$(CHART_NAME)/%: .build/setup_crane \
																							 .build/var/REGISTRY \
                                               .build/var/TRACK \
                                               .build/var/RELEASE \
                                               | .build/$(CHART_NAME)
	$(call print_target,$*)

	"$(CRANE_BIN)" copy "$(image-$*)" "$(REGISTRY)/$(APP_ID)/$*:$(TRACK)"
	"$(CRANE_BIN)" copy "$(image-$*)" "$(REGISTRY)/$(APP_ID)/$*:$(RELEASE)"
	@touch "$@"


.build/$(CHART_NAME)/tester: .build/setup_crane \
														 .build/var/APP_TESTER_IMAGE \
                             $(shell find apptest -type f) \
                             | .build/$(CHART_NAME)
	$(call print_target,$@)

	TESTER_BUILDER="tester-builder-$$(openssl rand -base64 12 | tr -dc 'a-z0-9' | head -c 8)"; \
	docker buildx create --name "$$TESTER_BUILDER" --use \
		&& docker buildx inspect "$$TESTER_BUILDER" --bootstrap \
		&& cd apptest/tester \
		&& docker buildx build \
				--push \
				--annotation="index,manifest:com.googleapis.cloudmarketplace.product.service.name=$(SERVICE_NAME)" \
				--tag "$(APP_TESTER_IMAGE)" .  \
		&& docker buildx rm "$$TESTER_BUILDER"
	@touch "$@"


########### Main  targets ###########


.PHONY: .build/$(CHART_NAME)/VERSION
.build/$(CHART_NAME)/VERSION: .build/setup_crane \
															| .build/$(CHART_NAME)
	$(call print_target,$@)
	@echo "$(C2D_CONTAINER_RELEASE)" | grep -qE "^$(TRACK)\.[0-9]+(\.[0-9]+)?$$" || \
	( echo "C2D_RELEASE doesn't start with TRACK or doesn't match TRACK exactly"; exit 1 )


endif
