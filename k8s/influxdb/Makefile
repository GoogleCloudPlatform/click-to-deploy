include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 1.7
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/influxdb/deployer:$(TAG)
NAME ?= influxdb-1
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/influxdb/deployer \
            .build/influxdb/influxdb


.build/influxdb: | .build
	mkdir -p "$@"


.build/influxdb/deployer: deployer/* \
                           manifest/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/influxdb
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/influxdb" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/influxdb/influxdb: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/influxdb
	docker pull launcher.gcr.io/google/influxdb1:$(TAG)
	docker tag launcher.gcr.io/google/influxdb1:$(TAG) \
	    "$(REGISTRY)/influxdb:$(TAG)"
	docker push "$(REGISTRY)/influxdb:$(TAG)"
	@touch "$@"
