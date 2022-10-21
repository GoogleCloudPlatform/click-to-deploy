include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := longhorn
APP_ID ?= $(CHART_NAME)
WAIT_FOR_READY_TIMEOUT := 600

TRACK ?= 1.3
# Track for components
LONGHORN_TRACK ?= v1.3.2
LONGHORN_MANAGERS_TRACK ?= v1.3.x-head
CSI_ATTACHER_TRACK ?= v3.4.0
CSI_PROVISIONER_TRACK ?= v2.1.2
CSI_NODE_DRIVER_REGISTRAR_TRACK ?= v2.5.0
CSI_RESIZER_TRACK ?= v1.2.0
CSI_SNAPSHOTTER_TRACK ?= v3.0.3

VERIFY_WAIT_TIMEOUT = 1800

MARKETPLACE_SOURCE_REGISTRY ?= marketplace.gcr.io/google
LONGHORN_SOURCE_REGISTRY ?= docker.io/longhornio

IMAGE_LONGHORN ?= $(MARKETPLACE_SOURCE_REGISTRY)/longhorn1:$(TRACK)

# Longhorn components
IMAGE_LONGHORN_ENGINE ?= $(LONGHORN_SOURCE_REGISTRY)/longhorn-engine:$(LONGHORN_TRACK)
IMAGE_LONGHORN_MANAGER ?= $(LONGHORN_SOURCE_REGISTRY)/longhorn-manager:$(LONGHORN_TRACK)
IMAGE_LONGHORN_UI ?= $(LONGHORN_SOURCE_REGISTRY)/longhorn-ui:$(LONGHORN_TRACK)
IMAGE_LONGHORN_INSTACE_MANAGER ?= $(LONGHORN_SOURCE_REGISTRY)/longhorn-instance-manager:$(LONGHORN_MANAGERS_TRACK)
IMAGE_LONGHORN_SHARE_MANAGER ?= $(LONGHORN_SOURCE_REGISTRY)/longhorn-share-manager:$(LONGHORN_MANAGERS_TRACK)
IMAGE_LONGHORN_BACKING_IMAGE_MANAGER ?= $(LONGHORN_SOURCE_REGISTRY)/backing-image-manager:$(LONGHORN_MANAGERS_TRACK)
IMAGE_LONGHORN_CSI_ATTACHER ?= $(LONGHORN_SOURCE_REGISTRY)/csi-attacher:$(CSI_ATTACHER_TRACK)
IMAGE_LONGHORN_CSI_PROVISIONER ?= $(LONGHORN_SOURCE_REGISTRY)/csi-provisioner:$(CSI_PROVISIONER_TRACK)
IMAGE_LONGHORN_CSI_NODE_DRIVER_REGISTRAR ?= $(LONGHORN_SOURCE_REGISTRY)/csi-node-driver-registrar:$(CSI_NODE_DRIVER_REGISTRAR_TRACK)
IMAGE_LONGHORN_CSI_RESIZER ?= $(LONGHORN_SOURCE_REGISTRY)/csi-resizer:$(CSI_RESIZER_TRACK)
IMAGE_LONGHORN_CSI_SNAPSHOTTER ?= $(LONGHORN_SOURCE_REGISTRY)/csi-snapshotter:$(CSI_SNAPSHOTTER_TRACK)

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_LONGHORN))

# List of images used in application
ADDITIONAL_IMAGES := longhorn-engine longhorn-manager longhorn-ui longhorn-instance-manager longhorn-share-manager longhorn-backing-image-manager longhorn-csi-attacher longhorn-csi-provisioner longhorn-node-driver-registrar longhorn-csi-resizer longhorn-csi-snapshotter

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
