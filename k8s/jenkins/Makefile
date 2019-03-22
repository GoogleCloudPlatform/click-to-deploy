include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 2.150
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/jenkins/deployer:$(TAG)
NAME ?= jenkins-1

ifdef IMAGE_JENKINS
  IMAGE_JENKINS_FIELD = , "IMAGE_JENKINS": "$(IMAGE_JENKINS)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_JENKINS_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/jenkins/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
}


app/build:: .build/jenkins/deployer \
            .build/jenkins/jenkins \
            .build/jenkins/tester


.build/jenkins: | .build
	mkdir -p "$@"


.build/jenkins/deployer: deployer/* \
                         manifest/* \
                         schema.yaml \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/MARKETPLACE_TOOLS_TAG \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/jenkins
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/jenkins" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .

	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/jenkins/jenkins: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/jenkins

	docker pull "launcher.gcr.io/google/jenkins2:$(TAG)"
	docker tag "launcher.gcr.io/google/jenkins2:$(TAG)" \
	    "$(REGISTRY)/jenkins:$(TAG)"
	docker push "$(REGISTRY)/jenkins:$(TAG)"
	@touch "$@"


.build/jenkins/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/jenkins
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
