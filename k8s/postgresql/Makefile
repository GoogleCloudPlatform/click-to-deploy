include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= 9.6
SRCTAG ?= 9.6-kubernetes
IMAGE_POSTGRESQL ?= launcher.gcr.io/google/postgresql9:$(SRCTAG)
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/postgresql/deployer:$(TAG)
NAME ?= postgresql-1
APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

TESTER_IMAGE ?= $(REGISTRY)/postgresql/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/postgresql/deployer \
            .build/postgresql/postgresql \
            .build/postgresql/tester


.build/postgresql: | .build
	mkdir -p "$@"


.build/postgresql/deployer: deployer/* \
                           chart/postgresql/* \
                           chart/postgresql/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/postgresql
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/postgresql" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
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


.build/postgresql/tester: .build/var/TESTER_IMAGE \
                          $(shell find apptest -type f) \
                          | .build/postgresql
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
