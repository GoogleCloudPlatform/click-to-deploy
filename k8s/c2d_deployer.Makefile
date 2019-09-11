#
# Used with app_v2 Makefile for deployer schema v2.
#

ifndef __C2D_DEPLOYER_MAKEFILE__

__C2D_DEPLOYER_MAKEFILE__:= included

include ../app_v2.Makefile


##### Helper targets #####

app/build:: $(APP_ID) \
            .build/$(APP_ID)/deployer \
            .build/images \
            .build/$(APP_ID)/tester \
            .build/$(APP_ID)/VERSION


.build/images: $(TARGET_IMAGES)


.build/$(APP_ID): | .build
	mkdir -p "$@"


.build/$(APP_ID)/deployer: deployer/* \
                           chart/$(APP_ID)/* \
                           chart/$(APP_ID)/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TRACK \
                           .build/var/RELEASE \
                           | .build/$(APP_ID)
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


.PHONY: $(APP_ID)
$(APP_ID): .build/var/REGISTRY \
           .build/var/TRACK \
           .build/var/RELEASE \
           | .build/$(APP_ID)
	docker pull $(image-$@)
	docker tag $(image-$@) "$(REGISTRY)/$@:$(TRACK)"
	docker tag $(image-$@) "$(REGISTRY)/$@:$(RELEASE)"
	docker push "$(REGISTRY)/$@:$(TRACK)"
	docker push "$(REGISTRY)/$@:$(RELEASE)"


$(TARGET_IMAGES): .build/var/REGISTRY \
                  .build/var/TRACK \
                  .build/var/RELEASE \
                  | .build/$(APP_ID)
	docker pull $(image-$@)
	docker tag $(image-$@) "$(REGISTRY)/$(APP_ID)/$@:$(TRACK)"
	docker tag $(image-$@) "$(REGISTRY)/$(APP_ID)/$@:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/$@:$(TRACK)"
	docker push "$(REGISTRY)/$(APP_ID)/$@:$(RELEASE)"


.build/$(APP_ID)/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/$(APP_ID)
	$(call print_target,$@)
	cd apptest/tester \
		&& docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


########### Main  targets ###########


.PHONY: .build/$(APP_ID)/VERSION
.build/$(APP_ID)/VERSION:
	echo "$(C2D_CONTAINER_RELEASE)" | grep -G "^$(TRACK).*$$" || \
	( echo "C2D_RELEASE doesn't start with TRACK or doesn't match TRACK exactly"; exit 1 )


endif
