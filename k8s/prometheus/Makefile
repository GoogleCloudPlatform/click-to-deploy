TAG ?= latest

# crd.Makefile provides targets to install Application CRD.
include ../vendor/marketplace-tools/crd.Makefile

# gcloud.Makefile provides default values for
# REGISTRY and NAMESPACE derived from local
# gcloud and kubectl environments.
include ../vendor/marketplace-tools/gcloud.Makefile

# marketplace.Makefile provides targets such as
# ".build/marketplace/deployer/envsubst" to build the base
# deployer images locally.
include ../vendor/marketplace-tools/marketplace.Makefile

# ubbagent.Makefile provides ".build/ubbagent/ubbagent"
# target to build the ubbagent image locally.
include ../vendor/marketplace-tools/ubbagent.Makefile
include ../vendor/marketplace-tools/var.Makefile

# app.Makefile provides the main targets for installing the
# application.
# It requires several APP_* variables defined as followed.
include ../vendor/marketplace-tools/app.Makefile

APP_DEPLOYER_IMAGE ?= $(REGISTRY)/prometheus/deployer:$(TAG)
NAME ?= prometheus-1

ifdef IMAGE_PROMETHEUS
  IMAGE_PROMETHEUS_FIELD = , "IMAGE_PROMETHEUS": "$(IMAGE_PROMETHEUS)"
endif

ifdef IMAGE_ALERTMANAGER
  IMAGE_ALERTMANAGER_FIELD = , "IMAGE_ALERTMANAGER": "$(IMAGE_ALERTMANAGER)"
endif

ifdef IMAGE_NODE_EXPORTER
  IMAGE_NODE_EXPORTER_FIELD = , "IMAGE_NODE_EXPORTER": "$(IMAGE_NODE_EXPORTER)"
endif

ifdef IMAGE_PUSHGATEWAY
  IMAGE_PUSHGATEWAY_FIELD = , "IMAGE_PUSHGATEWAY": "$(IMAGE_PUSHGATEWAY)"
endif

ifdef IMAGE_KUBE_STATE_METRICS
  IMAGE_KUBE_STATE_METRICS_FIELD = , "IMAGE_KUBE_STATE_METRICS": "$(IMAGE_KUBE_STATE_METRICS)"
endif

ifdef IMAGE_GRAFANA
  IMAGE_GRAFANA_FIELD = , "IMAGE_GRAFANA": "$(IMAGE_GRAFANA)"
endif

ifdef IMAGE_PROMETHEUS_INIT
  IMAGE_PROMETHEUS_INIT_FIELD = , "IMAGE_PROMETHEUS_INIT": "$(IMAGE_PROMETHEUS_INIT)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_ALERTMANAGER_FIELD) \
  $(IMAGE_KUBE_STATE_METRICS_FIELD) \
  $(IMAGE_NODE_EXPORTER_FIELD) \
  $(IMAGE_PROMETHEUS_FIELD) \
  $(IMAGE_PUSHGATEWAY_FIELD) \
  $(IMAGE_GRAFANA_FIELD) \
  $(IMAGE_PROMETHEUS_INIT_FIELD) \
}

# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/prometheus/deployer \
             .build/prometheus/debian9
#            .build/prometheus/alertmanager \
#            .build/prometheus/kubestatemetrics \
#            .build/prometheus/nodeexporter \
#            .build/prometheus/server \
#            .build/prometheus/pushgateway \
#            .build/prometheus/grafana \



.build/prometheus: | .build
	mkdir -p "$@"


.build/prometheus/deployer: deployer/* \
							manifest/* \
							schema.yaml \
							.build/marketplace/deployer/helm \
							.build/var/APP_DEPLOYER_IMAGE \
							.build/var/REGISTRY \
							.build/var/TAG \
							| .build/prometheus
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)" \
	    --build-arg TAG="$(TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


## Simulate building of primary app image. Actually just copying public image to
## local registry.
#.build/prometheus/alertmanager: .build/var/REGISTRY \
#								.build/var/TAG \
#								| .build/prometheus
#	docker pull launcher.gcr.io/google/prometheus-alertmanager0:0.14
#	docker tag launcher.gcr.io/google/prometheus-alertmanager0:0.14 \
#	  "$(REGISTRY)/prometheus/alertmanager:$(TAG)"
#	docker push "$(REGISTRY)/prometheus/alertmanager:$(TAG)"
#	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/debian9: .build/var/REGISTRY \
								 .build/var/TAG \
								 | .build/prometheus
	docker pull launcher.gcr.io/google/debian9
	docker tag launcher.gcr.io/google/debian9 "$(REGISTRY)/prometheus/debian9:$(TAG)"
	docker push "$(REGISTRY)/prometheus/debian9:$(TAG)"
	@touch "$@"
#
#
## Simulate building of primary app image. Actually just copying public image to
## local registry.
#.build/prometheus/kubestatemetrics: .build/var/REGISTRY \
#									.build/var/TAG \
#									| .build/prometheus
#	docker pull launcher.gcr.io/google/kube-state-metrics1:1.3
#	docker tag launcher.gcr.io/google/kube-state-metrics1:1.3 \
#	  "$(REGISTRY)/prometheus/kubestatemetrics:$(TAG)"
#	docker push "$(REGISTRY)/prometheus/kubestatemetrics:$(TAG)"
#	@touch "$@"
#
#
## Simulate building of primary app image. Actually just copying public image to
## local registry.
#.build/prometheus/nodeexporter: .build/var/REGISTRY \
#								.build/var/TAG \
#								| .build/prometheus
#	docker pull launcher.gcr.io/google/prometheus-nodeexporter0:0.15
#	docker tag launcher.gcr.io/google/prometheus-nodeexporter0:0.15 \
#	  "$(REGISTRY)/prometheus/nodeexporter:$(TAG)"
#	docker push "$(REGISTRY)/prometheus/nodeexporter:$(TAG)"
#	@touch "$@"
#
#
## Simulate building of primary app image. Actually just copying public image to
## local registry.
## TODO: verify compatibility of prometheus version 2.3 with 2.2
#.build/prometheus/server: .build/var/REGISTRY \
#						  .build/var/TAG \
#						| .build/prometheus
#	docker pull launcher.gcr.io/google/prometheus2:2.3
#	docker tag launcher.gcr.io/google/prometheus2:2.3 "$(REGISTRY)/prometheus/server:$(TAG)"
#	docker push "$(REGISTRY)/prometheus/server:$(TAG)"
#	@touch "$@"
#
#
## Simulate building of primary app image. Actually just copying public image to
## local registry.
#.build/prometheus/grafana: .build/var/REGISTRY \
#						  .build/var/TAG \
#						| .build/prometheus
#	docker pull launcher.gcr.io/google/grafana5:5.0
#	docker tag launcher.gcr.io/google/grafana5:5.0 "$(REGISTRY)/prometheus/grafana:$(TAG)"
#	docker push "$(REGISTRY)/prometheus/grafana:$(TAG)"
#	@touch "$@"
#
#
## Simulate building of primary app image. Actually just copying public image to
## local registry.
#.build/prometheus/pushgateway: .build/var/REGISTRY \
#							   .build/var/TAG \
#							 | .build/prometheus
#	docker pull launcher.gcr.io/google/prometheus-pushgateway0:0.4
#	docker tag launcher.gcr.io/google/prometheus-pushgateway0:0.4 \
#	  "$(REGISTRY)/prometheus/pushgateway:$(TAG)"
#	docker push "$(REGISTRY)/prometheus/pushgateway:$(TAG)"
#	@touch "$@"
