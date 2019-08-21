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

ifndef GCS_URL
  # We replace ':' with '_' characters to support a now-deprecated
  # projects format "google.com:my-project".
  # Note that a project does not have any bucket by default.
  # This is just a conventional default value, where the user is expected
  # to create GCS bucket with the same name as the project
  GCS_URL := gs://$(shell gcloud config get-value project | tr ':' '_')
endif

ifndef NAMESPACE
  NAMESPACE := $(shell kubectl config view -o jsonpath="{.contexts[?(@.name==\"$$(kubectl config current-context)\")].context.namespace}")
  ifeq ($(NAMESPACE),)
    NAMESPACE = default
  endif
endif

$(info ---- REGISTRY = $(REGISTRY))
$(info ---- GCS_URL = $(GCS_URL))
$(info ---- NAMESPACE = $(NAMESPACE))

endif
