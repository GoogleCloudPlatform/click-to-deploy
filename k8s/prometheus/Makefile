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
  IMAGE_PROMETHEUS_FIELD = , "server.image.reference": "$(IMAGE_PROMETHEUS)"
endif

ifdef IMAGE_ALERTMANAGER
  IMAGE_ALERTMANAGER_FIELD = , "alertmanager.image.reference": "$(IMAGE_ALERTMANAGER)"
endif

ifdef IMAGE_NODE_EXPORTER
  IMAGE_NODE_EXPORTER_FIELD = , "nodeExporter.image.reference": "$(IMAGE_NODE_EXPORTER)"
endif

ifdef IMAGE_PUSHGATEWAY
  IMAGE_PUSHGATEWAY_FIELD = , "pushGateway.image.reference": "$(IMAGE_PUSHGATEWAY)"
endif

ifdef IMAGE_KUBE_STATE_METRICS
  IMAGE_KUBE_STATE_METRICS_FIELD = , "kubeStateMetrics.image.reference": "$(IMAGE_KUBE_STATE_METRICS)"
endif

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(IMAGE_ALERTMANAGER_FIELD) \
  ", configmapReload.image.reference": "$(REGISTRY)/prometheus/configmapreload:$(TAG)" \
  ", initChownData.image.reference": "$(REGISTRY)/prometheus/initchowndata:$(TAG)" \
  $(IMAGE_KUBE_STATE_METRICS) \
  $(IMAGE_NODE_EXPORTER_FIELD) \
  $(IMAGE_PROMETHEUS_FIELD) \
  $(IMAGE_PUSHGATEWAY_FIELD) \
}

# Extend the target as defined in app.Makefile to
# include real dependencies.
app/build:: .build/prometheus/deployer \
            .build/prometheus/alertmanager \
            .build/prometheus/configmapreload \
            .build/prometheus/initchowndata \
            .build/prometheus/kubestatemetrics \
            .build/prometheus/nodeexporter \
            .build/prometheus/server \
            .build/prometheus/pushgateway


.build/prometheus: | .build
	mkdir -p "$@"


.build/prometheus/deployer: deployer/* \
							prometheus/* \
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


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/alertmanager: .build/var/REGISTRY \
								.build/var/TAG \
								| .build/prometheus
	docker pull prom/alertmanager:v0.14.0
	docker tag prom/alertmanager:v0.14.0 "$(REGISTRY)/prometheus/alertmanager:$(TAG)"
	docker push "$(REGISTRY)/prometheus/alertmanager:$(TAG)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/configmapreload: .build/var/REGISTRY \
								   .build/var/TAG \
								 | .build/prometheus
	docker pull jimmidyson/configmap-reload:v0.1
	docker tag jimmidyson/configmap-reload:v0.1 "$(REGISTRY)/prometheus/configmapreload:$(TAG)"
	docker push "$(REGISTRY)/prometheus/configmapreload:$(TAG)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/initchowndata: .build/var/REGISTRY \
								 .build/var/TAG \
								 | .build/prometheus
	docker pull busybox
	docker tag busybox "$(REGISTRY)/prometheus/initchowndata:$(TAG)"
	docker push "$(REGISTRY)/prometheus/initchowndata:$(TAG)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/kubestatemetrics: .build/var/REGISTRY \
									.build/var/TAG \
									| .build/prometheus
	docker pull quay.io/coreos/kube-state-metrics:v1.3.1
	docker tag quay.io/coreos/kube-state-metrics:v1.3.1 "$(REGISTRY)/prometheus/kubestatemetrics:$(TAG)"
	docker push "$(REGISTRY)/prometheus/kubestatemetrics:$(TAG)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/nodeexporter: .build/var/REGISTRY \
								.build/var/TAG \
								| .build/prometheus
	docker pull prom/node-exporter:v0.15.2
	docker tag prom/node-exporter:v0.15.2 "$(REGISTRY)/prometheus/nodeexporter:$(TAG)"
	docker push "$(REGISTRY)/prometheus/nodeexporter:$(TAG)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/server: .build/var/REGISTRY \
						  .build/var/TAG \
						| .build/prometheus
	docker pull prom/prometheus:v2.2.1
	docker tag prom/prometheus:v2.2.1 "$(REGISTRY)/prometheus/server:$(TAG)"
	docker push "$(REGISTRY)/prometheus/server:$(TAG)"
	@touch "$@"


# Simulate building of primary app image. Actually just copying public image to
# local registry.
.build/prometheus/pushgateway: .build/var/REGISTRY \
							   .build/var/TAG \
							 | .build/prometheus
	docker pull prom/pushgateway:v0.4.0
	docker tag prom/pushgateway:v0.4.0 "$(REGISTRY)/prometheus/pushgateway:$(TAG)"
	docker push "$(REGISTRY)/prometheus/pushgateway:$(TAG)"
	@touch "$@"
