include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= 1.5
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
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/influxdb
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/influxdb" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/influxdb/influxdb: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/influxdb
	docker pull launcher.gcr.io/google/influxdb1:1.5
	docker tag launcher.gcr.io/google/influxdb1:1.5 \
	    "$(REGISTRY)/influxdb:$(TAG)"
	docker push "$(REGISTRY)/influxdb:$(TAG)"
	@touch "$@"
