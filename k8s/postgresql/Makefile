include ../vendor/marketplace-tools/app.Makefile
include ../vendor/marketplace-tools/crd.Makefile
include ../vendor/marketplace-tools/gcloud.Makefile
include ../vendor/marketplace-tools/marketplace.Makefile
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile


TAG ?= 9.6-kubernetes
IMAGE_POSTGRESQL ?= launcher.gcr.io/google/postgresql9:$(TAG)
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/postgresql/deployer:$(TAG)
NAME ?= postgresql-1
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/postgresql/deployer \
            .build/postgresql/postgresql


.build/postgresql: | .build
	mkdir -p "$@"


.build/postgresql/deployer: deployer/* \
                           manifest/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/postgresql
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/postgresql" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"

.build/postgresql/postgresql: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/postgresql
	docker pull $(IMAGE_POSTGRESQL)
	docker tag $(IMAGE_POSTGRESQL) "$(REGISTRY)/postgresql:$(TAG)"
	docker push "$(REGISTRY)/postgresql:$(TAG)"
	@touch "$@"

show-config:
	@psqlpass=$$(kubectl get secret/$(NAME)-secret -ojsonpath={.data.password} | base64 -d);\
	psqladdr=$$(kubectl get services/$(NAME)-postgresql-svc | awk '/^$(NAME)-postgresql/ {print $$4}');\
	psqluser=postgres;\
	echo;\
	echo -en "username: $$psqluser\n";\
	echo -en "password: $$psqlpass\n";\
	echo -en "address:  $$psqladdr\n";\
	echo;\
	echo "command:";\
	echo "PGPASSWORD=$$psqlpass psql sslmode=require -U$$psqluser -h $$psqladdr";\
	echo

