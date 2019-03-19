include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= latest
SRCTAG ?= latest
IMAGE_SONARQUBE ?= marketplace.gcr.io/google/sonarqube7:$(SRCTAG)
IMAGE_POSTGRESQL ?= marketplace.gcr.io/google/postgresql9:$(SRCTAG)

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/sonarqube/deployer:$(TAG)
NAME ?= sonarqube-1


APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/sonarqube/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/sonarqube/deployer \
            .build/sonarqube/sonarqube \
            .build/sonarqube/postgresql9 \
            .build/sonarqube/tester


.build/sonarqube: | .build
	mkdir -p "$@"

#.build/sonarqube/deps:
#	cp -r ../postgresql/chart/postgresql ./chart/sonarqube/charts/
#	rm -f ./chart/sonarqube/charts/postgresql/templates/application.yaml

.build/sonarqube/deployer: deployer/* \
                           chart/sonarqube/* \
                           chart/sonarqube/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/sonarqube
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/sonarqube" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

.build/sonarqube/sonarqube: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/sonarqube
	docker pull $(IMAGE_SONARQUBE)
	docker tag $(IMAGE_SONARQUBE) "$(REGISTRY)/sonarqube:$(TAG)"
	docker push "$(REGISTRY)/sonarqube:$(TAG)"
	@touch "$@"


.build/sonarqube/postgresql9: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/sonarqube
	docker pull $(IMAGE_POSTGRESQL)
	docker tag $(IMAGE_POSTGRESQL) "$(REGISTRY)/sonarqube/postgresql9:$(TAG)"
	docker push "$(REGISTRY)/sonarqube/postgresql9:$(TAG)"
	@touch "$@"




.build/sonarqube/tester: .build/var/TESTER_IMAGE \
                          $(shell find apptest -type f) \
                          | .build/sonarqube
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
