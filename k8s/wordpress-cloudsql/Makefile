include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

VERIFY_WAIT_TIMEOUT = 1800

TAG ?= latest
METRICS_EXPORTER_TAG ?= v0.5.1

$(info ---- TAG = $(TAG))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/wordpress-cloudsql/deployer:$(TAG)
NAME ?= wordpress-cloudsql-1

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

ifdef PUBLIC_SERVICE_AND_INGRESS_ENABLED
  PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD = , "enablePublicServiceAndIngress": "$(PUBLIC_SERVICE_AND_INGRESS_ENABLED)"
endif

ifdef METRICS_EXPORTER_ENABLED
  METRICS_EXPORTER_ENABLED_FIELD = , "metrics.enabled": "$(METRICS_EXPORTER_ENABLED)"
endif

ifdef GCP_PROJECT_ID
  GCP_PROJECT_ID_FIELD = , "cloudsql.GcpProjectId": "$(GCP_PROJECT_ID)"
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
  $(PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
  $(GCP_PROJECT_ID_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/wordpress-cloudsql/tester:$(TAG)


app/build:: .build/wordpress-cloudsql/deployer \
            .build/wordpress-cloudsql/wordpress \
            .build/wordpress-cloudsql/apache-exporter \
            .build/wordpress-cloudsql/mysql \
            .build/wordpress-cloudsql/mysqld-exporter \
            .build/wordpress-cloudsql/prometheus-to-sd \
            .build/wordpress-cloudsql/tester


.build/wordpress-cloudsql: | .build
	mkdir -p "$@"


.build/wordpress-cloudsql/deployer: deployer/* \
                                    chart/wordpress/* \
                                    chart/wordpress/templates/* \
                                    schema.yaml \
                                    .build/var/APP_DEPLOYER_IMAGE \
                                    .build/var/MARKETPLACE_TOOLS_TAG \
                                    .build/var/REGISTRY \
                                    .build/var/TAG \
                                    | .build/wordpress-cloudsql
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/wordpress-cloudsql" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/wordpress-cloudsql/wordpress: .build/var/REGISTRY \
                                     .build/var/TAG \
                                     | .build/wordpress-cloudsql
	docker pull marketplace.gcr.io/google/wordpress5-php7-apache:$(TAG)
	docker tag marketplace.gcr.io/google/wordpress5-php7-apache:$(TAG) \
	    "$(REGISTRY)/wordpress-cloudsql:$(TAG)"
	docker push "$(REGISTRY)/wordpress-cloudsql:$(TAG)"
	@touch "$@"


.build/wordpress-cloudsql/apache-exporter: .build/var/REGISTRY \
                                           .build/var/TAG \
                                           | .build/wordpress-cloudsql
	docker pull marketplace.gcr.io/google/wordpress5-php7-apache:exporter
	docker tag marketplace.gcr.io/google/wordpress5-php7-apache:exporter \
	    "$(REGISTRY)/wordpress-cloudsql/apache-exporter:$(TAG)"
	docker push "$(REGISTRY)/wordpress-cloudsql/apache-exporter:$(TAG)"
	@touch "$@"


.build/wordpress-cloudsql/mysql: .build/var/REGISTRY \
                                 .build/var/TAG \
                                 | .build/wordpress-cloudsql
	docker pull marketplace.gcr.io/google/mysql5:$(TAG)
	docker tag marketplace.gcr.io/google/mysql5:$(TAG) \
	    "$(REGISTRY)/wordpress-cloudsql/mysql:$(TAG)"
	docker push "$(REGISTRY)/wordpress-cloudsql/mysql:$(TAG)"
	@touch "$@"


.build/wordpress-cloudsql/mysqld-exporter: .build/var/REGISTRY \
                                           .build/var/TAG \
                                           | .build/wordpress-cloudsql
	docker pull marketplace.gcr.io/google/mysql5:exporter
	docker tag marketplace.gcr.io/google/mysql5:exporter \
	    "$(REGISTRY)/wordpress-cloudsql/mysqld-exporter:$(TAG)"
	docker push "$(REGISTRY)/wordpress-cloudsql/mysqld-exporter:$(TAG)"
	@touch "$@"


.build/wordpress-cloudsql/prometheus-to-sd: .build/var/REGISTRY \
                                            .build/var/TAG \
                                            | .build/wordpress-cloudsql
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/wordpress-cloudsql/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/wordpress-cloudsql/prometheus-to-sd:$(TAG)"
	@touch "$@"


.build/wordpress-cloudsql/tester: .build/var/TESTER_IMAGE \
                                   $(shell find apptest -type f) \
                                   | .build/wordpress-cloudsql
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
