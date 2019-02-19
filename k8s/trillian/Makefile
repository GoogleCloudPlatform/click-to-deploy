include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 1.2.1
APP_DEPLOYER_IMAGE ?= $(REGISTRY)/trillian/deployer:$(TAG)
# Default Busybox image used by etcd-operator:
# https://github.com/coreos/etcd-operator/blob/16f0e1b3693483061f2a8252c0e361b06d216424/pkg/util/k8sutil/k8sutil.go#L64
BUSYBOX_IMAGE ?= busybox:1.28.0-glibc
ETCD_OPERATOR_IMAGE ?= quay.io/coreos/etcd-operator:v0.9.1
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

APP_PARAMETERS ?= { \
  "NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_TRILLIAN_LOGSERVER_FIELD) \
  $(IMAGE_TRILLIAN_LOGSIGNER_FIELD) \
  $(IMAGE_MYSQL_FIELD) \
  $(IMAGE_ETCD_OPERATOR_FIELD) \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/trillian/busybox \
            .build/trillian/db_server \
            .build/trillian/deployer \
            .build/trillian/etcd_operator \
            .build/trillian/log_server \
            .build/trillian/log_signer


.build/trillian: | .build
	mkdir -p "$@"


.build/trillian/busybox: .build/var/REGISTRY \
                         .build/var/TAG \
                       | .build/trillian
	docker pull "$(BUSYBOX_IMAGE)"
	docker tag "$(BUSYBOX_IMAGE)" \
	  "$(REGISTRY)/trillian/busybox:$(TAG)"
	docker push "$(REGISTRY)/trillian/busybox:$(TAG)"
	@touch "$@"


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


.build/trillian/etcd_operator: .build/var/REGISTRY \
                               .build/var/TAG \
                             | .build/trillian
	docker pull "$(ETCD_OPERATOR_IMAGE)"
	docker tag "$(ETCD_OPERATOR_IMAGE)" \
	  "$(REGISTRY)/trillian/etcd_operator:$(TAG)"
	docker push "$(REGISTRY)/trillian/etcd_operator:$(TAG)"
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
