include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= latest
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/trillian/deployer:$(TAG)
NAME ?= trillian-1

ifdef IMAGE_TRILLIAN_LOGSERVER
  IMAGE_TRILLIAN_LOGSERVER_FIELD = , "IMAGE_TRILLIAN_LOGSERVER": "$(IMAGE_TRILLIAN_LOGSERVER)"
endif

ifdef IMAGE_TRILLIAN_LOGSIGNER
  IMAGE_TRILLIAN_LOGSIGNER_FIELD = , "IMAGE_TRILLIAN_LOGSIGNER": "$(IMAGE_TRILLIAN_LOGSIGNER)"
endif

ifdef IMAGE_MYSQL
  IMAGE_MYSQL_FIELD = , "IMAGE_MYSQL": "$(IMAGE_MYSQL)"
endif

ifdef IMAGE_ETCD_OPERATOR
  IMAGE_ETCD_OPERATOR_FIELD = , "IMAGE_ETCD_OPERATOR": "$(IMAGE_ETCD_OPERATOR)"
endif

ifdef IMAGE_PROMETHEUS_TO_SD
  IMAGE_PROMETHEUS_TO_SD_FIELD = , "IMAGE_PROMETHEUS_TO_SD": "$(IMAGE_PROMETHEUS_TO_SD)"
endif

APP_PARAMETERS ?= { \
  "NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_TRILLIAN_LOGSERVER_FIELD) \
  $(IMAGE_TRILLIAN_LOGSIGNER_FIELD) \
  $(IMAGE_MYSQL_FIELD) \
  $(IMAGE_ETCD_OPERATOR) \
  $(IMAGE_PROMETHEUS_TO_SD_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/trillian/db_server \
            .build/trillian/deployer \
            .build/trillian/log_server \
            .build/trillian/log_signer


.build/trillian: | .build
	mkdir -p "$@"


.build/trillian/db_server: .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/trillian
	docker pull gcr.io/trillian-opensource-ci/db_server:$(TAG)
	docker tag gcr.io/trillian-opensource-ci/db_server:$(TAG) \
	  "$(REGISTRY)/trillian/db_server:$(TAG)"
	docker push "$(REGISTRY)/trillian/db_server:$(TAG)"
	@touch "$@"


.build/trillian/deployer: deployer/* \
                          manifest/* \
                          schema.yaml \
                          .build/var/APP_DEPLOYER_IMAGE \
                          .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/trillian
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/trillian" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/trillian/log_server: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/trillian
	docker pull gcr.io/trillian-opensource-ci/log_server:$(TAG)
	docker tag gcr.io/trillian-opensource-ci/log_server:$(TAG) \
	  "$(REGISTRY)/trillian/log_server:$(TAG)"
	docker push "$(REGISTRY)/trillian/log_server:$(TAG)"
	@touch "$@"


.build/trillian/log_signer: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/trillian
	docker pull gcr.io/trillian-opensource-ci/log_signer:$(TAG)
	docker tag gcr.io/trillian-opensource-ci/log_signer:$(TAG) \
	  "$(REGISTRY)/trillian/log_signer:$(TAG)"
	docker push "$(REGISTRY)/trillian/log_signer:$(TAG)"
	@touch "$@"

