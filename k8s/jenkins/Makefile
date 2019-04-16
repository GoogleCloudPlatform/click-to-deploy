include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


VERIFY_WAIT_TIMEOUT = 1800

TAG ?= 2.150
METRICS_EXPORTER_TAG ?= v0.5.1
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/jenkins/deployer:$(TAG)
IMAGE_JENKINS ?= $(REGISTRY)/jenkins:$(TAG)
NAME ?= jenkins-1

ifdef IMAGE_JENKINS
  IMAGE_JENKINS_FIELD = , "jenkins.image": "$(IMAGE_JENKINS)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_JENKINS_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/jenkins/tester:$(TAG)


app/build:: .build/jenkins/deployer \
            .build/jenkins/jenkins \
            .build/jenkins/prometheus-to-sd \
            .build/jenkins/tester


.build/jenkins: | .build
	mkdir -p "$@"


.build/jenkins/deployer: deployer/* \
                         chart/jenkins/* \
                         chart/jenkins/templates/* \
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

	docker pull "marketplace.gcr.io/google/jenkins2:$(TAG)"
	docker tag "marketplace.gcr.io/google/jenkins2:$(TAG)" \
	    "$(REGISTRY)/jenkins:$(TAG)"
	docker push "$(REGISTRY)/jenkins:$(TAG)"
	@touch "$@"

.build/jenkins/prometheus-to-sd: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/jenkins
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/jenkins/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/jenkins/prometheus-to-sd:$(TAG)"
	@touch "$@"

.build/jenkins/tester: .build/var/TESTER_IMAGE \
                       $(shell find apptest -type f) \
                       | .build/jenkins
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
