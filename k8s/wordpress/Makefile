include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

VERIFY_WAIT_TIMEOUT = 1800

TAG ?= 0.1
RELEASE ?= 0.1.0
METRICS_EXPORTER_TAG ?= v0.5.1

APP_ID ?= wordpress-managed-updates

$(info ---- TAG = $(TAG))
$(info ---- RELEASE = $(RELEASE))

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/$(APP_ID)/deployer:$(RELEASE)
APP_DEPLOYER_IMAGE_TRACK_TAG ?= $(REGISTRY)/$(APP_ID)/deployer:$(TAG)
APP_GCS_PATH ?= $(GCS_URL)/$(APP_ID)/$(TAG)

NAME ?= $(APP_ID)-1

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

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_MYSQL_FIELD) \
  $(ROOT_DB_PASSWORD_FIELD) \
  $(WORDPRESS_DB_PASSWORD_FIELD) \
  $(WORDPRESS_ADMIN_EMAIL_FIELD) \
  $(WORDPRESS_ADMIN_PASSWORD_FIELD) \
  $(PUBLIC_SERVICE_AND_INGRESS_ENABLED_FIELD) \
  $(METRICS_EXPORTER_ENABLED_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/$(APP_ID)/tester:$(RELEASE)

# app_v2.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined above, and thus
# must be included after.
include ../app_v2.Makefile

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
                           .build/var/APP_DEPLOYER_IMAGE_TRACK_TAG \
                           .build/var/MARKETPLACE_TOOLS_TAG \
                           .build/var/REGISTRY \
                           .build/var/TAG \
                           .build/var/RELEASE \
                           | .build/wordpress
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/$(APP_ID)" \
	    --build-arg TAG="$(RELEASE)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker tag "$(APP_DEPLOYER_IMAGE)" "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	docker push "$(APP_DEPLOYER_IMAGE)"
	docker push "$(APP_DEPLOYER_IMAGE_TRACK_TAG)"
	@touch "$@"


.build/wordpress/wordpress: .build/var/REGISTRY \
                            .build/var/TAG \
                            .build/var/RELEASE \
                            | .build/wordpress
	docker pull marketplace.gcr.io/google/wordpress5-php7-apache:latest
	docker tag marketplace.gcr.io/google/wordpress5-php7-apache:latest \
	    "$(REGISTRY)/$(APP_ID):$(TAG)"
	docker tag "$(REGISTRY)/$(APP_ID):$(TAG)" "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID):$(TAG)"
	docker push "$(REGISTRY)/$(APP_ID):$(RELEASE)"
	@touch "$@"


.build/wordpress/apache-exporter: .build/var/REGISTRY \
                                  .build/var/TAG \
                                  .build/var/RELEASE \
                                  | .build/wordpress
	docker pull marketplace.gcr.io/google/wordpress5-php7-apache:exporter
	docker tag marketplace.gcr.io/google/wordpress5-php7-apache:exporter \
	    "$(REGISTRY)/$(APP_ID)/apache-exporter:$(TAG)"
	docker tag "$(REGISTRY)/$(APP_ID)/apache-exporter:$(TAG)" "$(REGISTRY)/$(APP_ID)/apache-exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/apache-exporter:$(TAG)"
	docker push "$(REGISTRY)/$(APP_ID)/apache-exporter:$(RELEASE)"
	@touch "$@"


.build/wordpress/mysql: .build/var/REGISTRY \
                        .build/var/TAG \
                        .build/var/RELEASE \
                        | .build/wordpress
	docker pull marketplace.gcr.io/google/mysql5:$(TAG)
	docker tag marketplace.gcr.io/google/mysql5:$(TAG) \
	    "$(REGISTRY)/$(APP_ID)/mysql:$(TAG)"
	docker tag "$(REGISTRY)/$(APP_ID)/mysql:$(TAG)" "$(REGISTRY)/$(APP_ID)/mysql:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/mysql:$(TAG)"
	docker push "$(REGISTRY)/$(APP_ID)/mysql:$(RELEASE)"
	@touch "$@"


.build/wordpress/mysqld-exporter: .build/var/REGISTRY \
                                  .build/var/TAG \
                                   .build/var/RELEASE \
                                  | .build/wordpress
	docker pull marketplace.gcr.io/google/mysql5:exporter
	docker tag marketplace.gcr.io/google/mysql5:exporter \
	    "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TAG)"
	docker tag "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TAG)" "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(TAG)"
	docker push "$(REGISTRY)/$(APP_ID)/mysqld-exporter:$(RELEASE)"
	@touch "$@"


.build/wordpress/prometheus-to-sd: .build/var/REGISTRY \
                                   .build/var/TAG \
                                   .build/var/RELEASE \
                                   | .build/wordpress
	docker pull k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)
	docker tag k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG) \
	    "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TAG)"
	docker tag "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TAG)" "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(TAG)"
	docker push "$(REGISTRY)/$(APP_ID)/prometheus-to-sd:$(RELEASE)"
	@touch "$@"


.build/wordpress/tester: .build/var/TESTER_IMAGE \
                         $(shell find apptest -type f) \
                         | .build/wordpress
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
