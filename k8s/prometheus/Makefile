include ../app.Makefile
include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile

TAG ?= 2.11

$(info ---- TAG = $(TAG))

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

ifdef IMAGE_KUBE_STATE_METRICS
  IMAGE_KUBE_STATE_METRICS_FIELD = , "IMAGE_KUBE_STATE_METRICS": "$(IMAGE_KUBE_STATE_METRICS)"
endif

ifdef IMAGE_GRAFANA
  IMAGE_GRAFANA_FIELD = , "IMAGE_GRAFANA": "$(IMAGE_GRAFANA)"
endif

ifdef IMAGE_PROMETHEUS_INIT
  IMAGE_PROMETHEUS_INIT_FIELD = , "IMAGE_PROMETHEUS_INIT": "$(IMAGE_PROMETHEUS_INIT)"
endif

ifdef PROMETHEUS_REPLICAS
  PROMETHEUS_REPLICAS_FIELD = , "PROMETHEUS_REPLICAS": "$(PROMETHEUS_REPLICAS)"
endif

APP_PARAMETERS ?= { \
  "APP_INSTANCE_NAME": "$(NAME)", \
  "NAMESPACE": "$(NAMESPACE)" \
  $(IMAGE_ALERTMANAGER_FIELD) \
  $(IMAGE_KUBE_STATE_METRICS_FIELD) \
  $(IMAGE_NODE_EXPORTER_FIELD) \
  $(IMAGE_PROMETHEUS_FIELD) \
  $(IMAGE_GRAFANA_FIELD) \
  $(IMAGE_PROMETHEUS_INIT_FIELD) \
  $(PROMETHEUS_REPLICAS_FIELD) \
}

TESTER_IMAGE ?= $(REGISTRY)/prometheus/tester:$(TAG)


app/build:: .build/prometheus/alertmanager \
            .build/prometheus/debian9 \
            .build/prometheus/deployer \
            .build/prometheus/grafana \
            .build/prometheus/kubestatemetrics \
            .build/prometheus/nodeexporter \
            .build/prometheus/server \
            .build/prometheus/tester


.build/prometheus: | .build
	mkdir -p "$@"


.build/prometheus/deployer: deployer/* \
                            manifest/* \
                            schema.yaml \
                            .build/var/APP_DEPLOYER_IMAGE \
                            .build/var/MARKETPLACE_TOOLS_TAG \
                            .build/var/REGISTRY \
                            .build/var/TAG \
                            | .build/prometheus
	docker build \
	    --build-arg REGISTRY="$(REGISTRY)/prometheus" \
	    --build-arg TAG="$(TAG)" \
	    --build-arg MARKETPLACE_TOOLS_TAG="$(MARKETPLACE_TOOLS_TAG)" \
	    --tag "$(APP_DEPLOYER_IMAGE)" \
	    -f deployer/Dockerfile \
	    .
	docker push "$(APP_DEPLOYER_IMAGE)"
	@touch "$@"


.build/prometheus/server: .build/var/REGISTRY \
                          .build/var/TAG \
                          | .build/prometheus
	docker pull marketplace.gcr.io/google/prometheus2:$(TAG)
	docker tag marketplace.gcr.io/google/prometheus2:$(TAG) "$(REGISTRY)/prometheus:$(TAG)"
	docker push "$(REGISTRY)/prometheus:$(TAG)"
	@touch "$@"


.build/prometheus/alertmanager: .build/var/REGISTRY \
                                .build/var/TAG \
                                | .build/prometheus
	docker pull marketplace.gcr.io/google/prometheus-alertmanager0:0.14
	docker tag marketplace.gcr.io/google/prometheus-alertmanager0:0.14 \
	  "$(REGISTRY)/prometheus/alertmanager:$(TAG)"
	docker push "$(REGISTRY)/prometheus/alertmanager:$(TAG)"
	@touch "$@"


.build/prometheus/debian9: .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/prometheus
	docker pull marketplace.gcr.io/google/debian9
	docker tag marketplace.gcr.io/google/debian9 "$(REGISTRY)/prometheus/debian9:$(TAG)"
	docker push "$(REGISTRY)/prometheus/debian9:$(TAG)"
	@touch "$@"


.build/prometheus/kubestatemetrics: .build/var/REGISTRY \
                                    .build/var/TAG \
                                    | .build/prometheus
	docker pull marketplace.gcr.io/google/kube-state-metrics1:1.3
	docker tag marketplace.gcr.io/google/kube-state-metrics1:1.3 \
	  "$(REGISTRY)/prometheus/kubestatemetrics:$(TAG)"
	docker push "$(REGISTRY)/prometheus/kubestatemetrics:$(TAG)"
	@touch "$@"


.build/prometheus/nodeexporter: .build/var/REGISTRY \
                                .build/var/TAG \
                                | .build/prometheus
	docker pull marketplace.gcr.io/google/prometheus-nodeexporter0:0.15
	docker tag marketplace.gcr.io/google/prometheus-nodeexporter0:0.15 \
	  "$(REGISTRY)/prometheus/nodeexporter:$(TAG)"
	docker push "$(REGISTRY)/prometheus/nodeexporter:$(TAG)"
	@touch "$@"


.build/prometheus/grafana: .build/var/REGISTRY \
                           .build/var/TAG \
                           | .build/prometheus
	docker pull marketplace.gcr.io/google/grafana6:6.5
	docker tag marketplace.gcr.io/google/grafana6:6.5 "$(REGISTRY)/prometheus/grafana:$(TAG)"
	docker push "$(REGISTRY)/prometheus/grafana:$(TAG)"
	@touch "$@"


.build/prometheus/tester: .build/var/TESTER_IMAGE \
                          $(shell find apptest -type f) \
                          | .build/prometheus
	$(call print_target,$@)
	cd apptest/tester \
	    && docker build --tag "$(TESTER_IMAGE)" .
	docker push "$(TESTER_IMAGE)"
	@touch "$@"
