include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

VERIFY_WAIT_TIMEOUT = 1800

TAG ?= latest
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/wordpress/deployer:$(TAG)
NAME ?= wordpress-1

ifdef IMAGE_WORDPRESS
  IMAGE_WORDPRESS_FIELD = , "wordpressImage": "$(IMAGE_WORDPRESS)"
endif

ifdef IMAGE_MYSQL
  IMAGE_MYSQL_FIELD = , "db.image": "$(IMAGE_MYSQL)"
endif

ifdef ROOT_DB_PASSWORD
  ROOT_DB_PASSWORD_FIELD = , "db.rootPassword": "$(ROOT_DB_PASSWORD)"
endif

ifdef WORDPRESS_DB_PASSWORD
  WORDPRESS_DB_PASSWORD_FIELD = , "db.wordpressPassword": "$(WORDPRESS_DB_PASSWORD)"
endif

ifdef WORDPRESS_ADMIN_EMAIL
  WORDPRESS_ADMIN_EMAIL_FIELD = , "admin.email": "$(WORDPRESS_ADMIN_EMAIL)"
endif

ifdef WORDPRESS_ADMIN_PASSWORD
  WORDPRESS_ADMIN_PASSWORD_FIELD = , "admin.password": "$(WORDPRESS_ADMIN_PASSWORD)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_WORDPRESS_FIELD) \
  $(IMAGE_MYSQL_FIELD) \
  $(ROOT_DB_PASSWORD_FIELD) \
  $(WORDPRESS_DB_PASSWORD_FIELD) \
  $(WORDPRESS_ADMIN_EMAIL_FIELD) \
  $(WORDPRESS_ADMIN_PASSWORD_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/wordpress/tester:$(TAG)


app/build:: .build/wordpress/deployer \
            .build/wordpress/wordpress \
            .build/wordpress/apache-exporter \
            .build/wordpress/mysql \
            .build/wordpress/mysqld-exporter \
            .build/wordpress/prometheus-to-sd \
            .build/wordpress/tester


.build/wordpress: | .build
	mkdir -p "$@"


.build/wordpress/deployer: deployer/* \
                           chart/wordpress/* \
                           chart/wordpress/templates/* \
                           schema.yaml \
                           .build/var/APP_DEPLOYER_IMAGE \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/wordpress
	echo $(MARKETPLACE_TOOLS_TAG)
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
	docker pull marketplace.gcr.io/google/wordpress5-php7-apache:$(TAG)
	docker tag marketplace.gcr.io/google/wordpress5-php7-apache:$(TAG) \
	    "$(REGISTRY)/wordpress:$(TAG)"
	docker push "$(REGISTRY)/wordpress:$(TAG)"
	@touch "$@"


.build/wordpress/apache-exporter: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/wordpress
	docker pull marketplace.gcr.io/google/wordpress5-php7-apache:exporter
	docker tag marketplace.gcr.io/google/wordpress5-php7-apache:exporter \
	    "$(REGISTRY)/wordpress/apache-exporter:$(TAG)"
	docker push "$(REGISTRY)/wordpress/apache-exporter:$(TAG)"
	@touch "$@"


.build/wordpress/mysql: .build/var/REGISTRY \
                        .build/var/TAG \
                        | .build/wordpress
	docker pull marketplace.gcr.io/google/mysql5:$(TAG)
	docker tag marketplace.gcr.io/google/mysql5:$(TAG) \
	    "$(REGISTRY)/wordpress/mysql:$(TAG)"
	docker push "$(REGISTRY)/wordpress/mysql:$(TAG)"
	@touch "$@"


.build/wordpress/mysqld-exporter: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  | .build/wordpress
	docker pull marketplace.gcr.io/google/mysql5:exporter
	docker tag marketplace.gcr.io/google/mysql5:exporter \
	    "$(REGISTRY)/wordpress/mysqld-exporter:$(TAG)"
	docker push "$(REGISTRY)/wordpress/mysqld-exporter:$(TAG)"
	@touch "$@"


.build/wordpress/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   | .build/wordpress
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/wordpress/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/wordpress/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/wordpress/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/wordpress
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
