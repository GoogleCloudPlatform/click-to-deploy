include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile


TAG ?= latest
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/wordpress/deployer:$(TAG)
NAME ?= wordpress-1
APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
}
APP_TEST_PARAMETERS ?= {}


app/build:: .build/wordpress/deployer \
            .build/wordpress/mysql \
            .build/wordpress/wordpress


.build/wordpress: | .build
	mkdir -p "$@"


.build/wordpress/deployer: deployer/* \
                           manifest/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/wordpress
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/wordpress" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/wordpress/wordpress: .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/wordpress
	docker pull launcher.gcr.io/google/wordpress4-php7-apache:$(TAG)
	docker tag launcher.gcr.io/google/wordpress4-php7-apache:$(TAG) \
	    "$(REGISTRY)/wordpress:$(TAG)"
	docker push "$(REGISTRY)/wordpress:$(TAG)"
	@touch "$@"


.build/wordpress/mysql: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/wordpress
	docker pull launcher.gcr.io/google/mysql5
	docker tag launcher.gcr.io/google/mysql5 \
	    "$(REGISTRY)/wordpress/mysql:$(TAG)"
	docker push "$(REGISTRY)/wordpress/mysql:$(TAG)"
	@touch "$@"
