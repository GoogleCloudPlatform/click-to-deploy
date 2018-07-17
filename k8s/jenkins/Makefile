include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= 2.121
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/jenkins/deployer:$(TAG)
NAME ?= jenkins-1

ifdef IMAGE_JENKINS
  IMAGE_JENKINS_FIELD = , "IMAGE_JENKINS": "$(IMAGE_JENKINS)"
endif

ifdef IMAGE_JENKINS_INIT
  IMAGE_JENKINS_INIT_FIELD = , "IMAGE_JENKINS_INIT": "$(IMAGE_JENKINS_INIT)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_JENKINS_FIELD) \
  $(IMAGE_JENKINS_INIT_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/jenkins/deployer \
            .build/jenkins/jenkins


.build/jenkins: | .build
	mkdir -p "$@"


.build/jenkins/deployer: deployer/* \
                         manifest/* \
                         .build/var/APP_DEPLOYER_IMAGE \
                         .build/var/REGISTRY \
                         .build/var/TAG \
                         | .build/jenkins
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/jenkins" \
	    --build-arg TAG="$(TAG)" \
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
