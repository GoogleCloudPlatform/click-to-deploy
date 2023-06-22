include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := knative
APP_ID ?= $(CHART_NAME)
WAIT_FOR_READY_TIMEOUT := 600

TRACK ?= 1.9
# Track for components
KNATIVE_TRACK ?= v1.9.0
ISTIO_TRACK ?= 1.16.0
CM_TRACK ?= 1.11

METRICS_EXPORTER_TAG ?= v0.5.1

VERIFY_WAIT_TIMEOUT = 1800

MARKETPLACE_SOURCE_REGISTRY ?= marketplace.gcr.io/google
KNATIVE_SOURCE_REGISTRY ?= gcr.io/knative-releases/knative.dev

IMAGE_KNATIVE ?= $(MARKETPLACE_SOURCE_REGISTRY)/knative1:$(TRACK)

# CERT MANAGER
IMAGE_CERTMANAGER ?= $(MARKETPLACE_SOURCE_REGISTRY)/cert-manager1:$(CM_TRACK)

# ISTIO
IMAGE_ISTIO_INGRESSGATEWAY ?= gcr.io/istio-release/proxyv2:$(ISTIO_TRACK)
IMAGE_ISTIO_ISTIOD ?= gcr.io/istio-release/pilot:$(ISTIO_TRACK)

# KNATIVE SERVING
IMAGE_KNATIVE_SERVING_ACTIVATOR ?= $(KNATIVE_SOURCE_REGISTRY)/serving/cmd/activator:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_AUTOSCALER ?= $(KNATIVE_SOURCE_REGISTRY)/serving/cmd/autoscaler:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_CONTROLLER ?= $(KNATIVE_SOURCE_REGISTRY)/serving/cmd/controller:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_DOMAINMAPPING ?= $(KNATIVE_SOURCE_REGISTRY)/serving/cmd/domain-mapping:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_DOMAINMAPPING_WEBHOOK ?= $(KNATIVE_SOURCE_REGISTRY)/serving/cmd/domain-mapping-webhook:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_QUEUEPROXY ?= $(KNATIVE_SOURCE_REGISTRY)/serving/cmd/queue:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_WEBHOOK ?= $(KNATIVE_SOURCE_REGISTRY)/serving/cmd/webhook:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_NETCERMANAGER_CONTROLLER ?= $(KNATIVE_SOURCE_REGISTRY)/net-certmanager/cmd/controller:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_NETCERMANAGER_WEBHOOK ?= $(KNATIVE_SOURCE_REGISTRY)/net-certmanager/cmd/webhook:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_NETISTIO_CONTROLLER ?= $(KNATIVE_SOURCE_REGISTRY)/net-istio/cmd/controller:$(KNATIVE_TRACK)
IMAGE_KNATIVE_SERVING_NETISTIO_WEBHOOK ?= $(KNATIVE_SOURCE_REGISTRY)/net-istio/cmd/webhook:$(KNATIVE_TRACK)

# KNATIVE EVENTING
IMAGE_KNATIVE_EVENTING_CONTROLLER ?= $(KNATIVE_SOURCE_REGISTRY)/eventing/cmd/controller:$(KNATIVE_TRACK)
IMAGE_KNATIVE_EVENTING_MTPING ?= $(KNATIVE_SOURCE_REGISTRY)/eventing/cmd/mtping:$(KNATIVE_TRACK)
IMAGE_KNATIVE_EVENTING_WEBHOOK ?= $(KNATIVE_SOURCE_REGISTRY)/eventing/cmd/webhook:$(KNATIVE_TRACK)

#IMAGE_PROMETHEUS_TO_SD ?= k8s.gcr.io/prometheus-to-sd:$(METRICS_EXPORTER_TAG)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_KNATIVE))

# List of images used in application
ADDITIONAL_IMAGES := certmanager istio-ingressgateway istio-istiod knative-serving-activator knative-serving-autoscaler knative-serving-controller knative-serving-domainmapping knative-serving-domainmapping-webhook knative-serving-queueproxy knative-serving-webhook knative-serving-netcertmanager-controller knative-serving-netcertmanager-webhook knative-serving-netistio-controller knative-serving-netistio-webhook knative-eventing-controller knative-eventing-mtping knative-eventing-webhook

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-certmanager := $(call get_sha256,$(IMAGE_CERTMANAGER))
image-istio-ingressgateway := $(call get_sha256,$(IMAGE_ISTIO_INGRESSGATEWAY))
image-istio-istiod := $(call get_sha256,$(IMAGE_ISTIO_ISTIOD))
image-knative-serving-activator := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_ACTIVATOR))
image-knative-serving-autoscaler := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_AUTOSCALER))
image-knative-serving-controller := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_CONTROLLER))
image-knative-serving-domainmapping := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_DOMAINMAPPING))
image-knative-serving-domainmapping-webhook := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_DOMAINMAPPING_WEBHOOK))
image-knative-serving-queueproxy := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_QUEUEPROXY))
image-knative-serving-webhook := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_WEBHOOK))
image-knative-serving-netcertmanager-controller := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_NETCERMANAGER_CONTROLLER))
image-knative-serving-netcertmanager-webhook := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_NETCERMANAGER_WEBHOOK))
image-knative-serving-netistio-controller := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_NETISTIO_CONTROLLER))
image-knative-serving-netistio-webhook := $(call get_sha256,$(IMAGE_KNATIVE_SERVING_NETISTIO_WEBHOOK))
image-knative-eventing-controller := $(call get_sha256,$(IMAGE_KNATIVE_EVENTING_CONTROLLER))
image-knative-eventing-mtping := $(call get_sha256,$(IMAGE_KNATIVE_EVENTING_MTPING))
image-knative-eventing-webhook := $(call get_sha256,$(IMAGE_KNATIVE_EVENTING_WEBHOOK))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
