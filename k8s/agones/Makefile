include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 0.8.1
NAME ?= agones


$(info ---- TAG = $(TAG))


# source repo and destination tags for images
SOURCE_REGISTRY ?= gcr.io/agones-images
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/agones/deployer:$(TAG)
AGONES_CONTROLLER_IMAGE ?= $(REGISTRY)/agones:$(TAG)
AGONES_SDK_IMAGE ?= $(REGISTRY)/agones/agones-sdk:$(TAG)
AGONES_PING_IMAGE ?= $(REGISTRY)/agones/agones-ping:$(TAG)


APP_PARAMETERS ?= { \
    "APP_INSTANCE_NAME": "$(NAME)", \
    "NAMESPACE": "$(NAMESPACE)" \
}


APP_TEST_PARAMETERS ?= { \
}


app/build:: .build/agones/deployer \
            .build/agones/agones-controller \
            .build/agones/agones-sdk \
            .build/agones/agones-ping


.build/agones: | .build
	mkdir -p "$@"


.build/agones/deployer: deployer/* \
                        chart/agones-mp/* \
                        chart/agones-mp/templates/* \
                        scripts/* \
                        schema.yaml \
                        .build/var/APP_DEPLOYER_IMAGE \
                        .build/var/MARKETPLACE_TOOLS_TAG \
                        .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/agones
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/agones" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/agones/agones-controller: .build/var/REGISTRY \
                                 .build/var/TAG \
                                 | .build/agones
	docker pull $(SOURCE_REGISTRY)/agones-controller:$(TAG)
	docker tag $(SOURCE_REGISTRY)/agones-controller:$(TAG) \
	    "$(AGONES_CONTROLLER_IMAGE)"
	docker push "$(AGONES_CONTROLLER_IMAGE)"
	@touch "$@"


.build/agones/agones-sdk: .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/agones
	docker pull $(SOURCE_REGISTRY)/agones-sdk:$(TAG)
	docker tag $(SOURCE_REGISTRY)/agones-sdk:$(TAG) \
	    "$(AGONES_SDK_IMAGE)"
	docker push "$(AGONES_SDK_IMAGE)"
	@touch "$@"


.build/agones/agones-ping: .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/agones
	docker pull $(SOURCE_REGISTRY)/agones-ping:$(TAG)
	docker tag $(SOURCE_REGISTRY)/agones-ping:$(TAG) \
	    "$(AGONES_PING_IMAGE)"
	docker push "$(AGONES_PING_IMAGE)"
	@touch "$@"
