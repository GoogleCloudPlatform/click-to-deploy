include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= alpha
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/airflow-operator/deployer:$(TAG)
NAME ?= airflow-operator-1

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/airflow-operator/tester:$(TAG)


app/build:: .build/airflow-operator/deployer \
            .build/airflow-operator/airflow-operator \
            .build/airflow-operator/tester


.build/airflow-operator: | .build
	mkdir -p "$@"


.build/airflow-operator/deployer: deployer/* \
                                  manifest/* \
                                  schema.yaml \
                                  .build/var/APP_DEPLOYER_IMAGE \
                                  .build/var/MARKETPLACE_TOOLS_TAG \
                                  .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/airflow-operator
	$(call print_target, $@)
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/airflow-operator" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/airflow-operator/tester: apptest/**/* \
                                | .build/airflow-operator
	$(call print_target, $@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"


.build/airflow-operator/airflow-operator: .build/var/REGISTRY \
                                          .build/var/TAG \
                                          | .build/airflow-operator
	$(call print_target, $@)
	docker pull gcr.io/airflow-operator/airflow-operator:v1alpha1
	docker tag gcr.io/airflow-operator/airflow-operator:v1alpha1 "$(REGISTRY)/airflow-operator:$(TAG)"
	docker push "$(REGISTRY)/airflow-operator:$(TAG)"
	@touch "$@"
