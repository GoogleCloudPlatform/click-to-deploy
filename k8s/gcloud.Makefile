ifndef __GCLOUD_MAKEFILE__

__GCLOUD_MAKEFILE__ := included

# Include this Makefile to automatically derive registry
# and target namespace from the current gcloud and kubectl
# configurations.
# This is for convenience over having to specifying the
# environment variables manually.


ifndef REGISTRY
  # We replace ':' with '/' characters to support a now-deprecated
  # projects format "google.com:my-project".
  REGISTRY := gcr.io/$(shell gcloud config get-value project | tr ':' '/')
endif

ifndef NAMESPACE
  NAMESPACE := $(shell kubectl config view -o jsonpath="{.contexts[?(@.name==\"$$(kubectl config current-context)\")].context.namespace}")
  ifeq ($(NAMESPACE),)
    NAMESPACE = default
  endif
endif

$(info ---- REGISTRY = $(REGISTRY))
$(info ---- NAMESPACE = $(NAMESPACE))

endif
