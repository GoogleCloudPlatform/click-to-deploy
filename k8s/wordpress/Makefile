include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

VERIFY_WAIT_TIMEOUT ?= 1800

TAG ?= latest
$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/wordpress/deployer:$(TAG)
NAME ?= wordpress-1

ifdef IMAGE_WORDPRESS
  IMAGE_WORDPRESS_FIELD = , "IMAGE_WORDPRESS": "$(IMAGE_WORDPRESS)"
endif

ifdef IMAGE_MYSQL
  IMAGE_MYSQL_FIELD = , "IMAGE_MYSQL": "$(IMAGE_MYSQL)"
endif

ifdef ROOT_DB_PASSWORD
  ROOT_DB_PASSWORD_FIELD = , "ROOT_DB_PASSWORD": "$(ROOT_DB_PASSWORD)"
endif

ifdef WORDPRESS_DB_PASSWORD
  WORDPRESS_DB_PASSWORD_FIELD = , "WORDPRESS_DB_PASSWORD": "$(WORDPRESS_DB_PASSWORD)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_WORDPRESS_FIELD) \
  $(IMAGE_MYSQL_FIELD) \
  $(ROOT_DB_PASSWORD_FIELD) \
  $(WORDPRESS_DB_PASSWORD_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/wordpress/tester:$(TAG)

APP_TEST_PARAMETERS ?= { \
  "testerImage": "$(TESTER_IMAGE)" \
}


app/build:: .build/wordpress/deployer \
            .build/wordpress/mysql \
            .build/wordpress/wordpress \
            .build/wordpress/tester


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
	docker pull launcher.gcr.io/google/wordpress5-php7-apache:$(TAG)
	docker tag launcher.gcr.io/google/wordpress5-php7-apache:$(TAG) \
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

.build/wordpress/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/wordpress
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
