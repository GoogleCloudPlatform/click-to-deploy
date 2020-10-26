include ../crd.Makefile
include ../gcloud.Makefile
include ../var.Makefile
include ../images.Makefile

CHART_NAME := amppackager
APP_ID ?= $(CHART_NAME)

TRACK ?= 1.0

SOURCE_REGISTRY ?= $(REGISTRY)
IMAGE_AMPPACKAGER ?= $(SOURCE_REGISTRY)/amppackager1:$(TRACK)
IMAGE_INIT_CONTAINER ?= $(SOURCE_REGISTRY)/amppackager1/init:$(TRACK)

$(info ---- IMAGE_AMPPACKAGER = $(IMAGE_AMPPACKAGER))
$(info ---- IMAGE_AMPPACKAGER_INIT = $(IMAGE_INIT_CONTAINER))

# Main image
image-$(CHART_NAME) := $(call get_sha256,$(IMAGE_AMPPACKAGER))
$(info ---- image-$(CHART_NAME) = $(image-$(CHART_NAME)))

# List of images used in application
ADDITIONAL_IMAGES := init

# Additional images variable names should correspond with ADDITIONAL_IMAGES list
image-init := $(call get_sha256,$(IMAGE_INIT_CONTAINER))

C2D_CONTAINER_RELEASE := $(call get_c2d_release,$(image-$(CHART_NAME)))
$(info ---- C2D_CONTAINER_RELEASE = "$(C2D_CONTAINER_RELEASE)")

BUILD_ID := $(shell date --utc +%Y%m%d-%H%M%S)
RELEASE ?= $(C2D_CONTAINER_RELEASE)-$(BUILD_ID)
NAME ?= $(APP_ID)-1

# Additional variables
ifdef PACKAGER_DOMAIN
  PACKAGER_DOMAIN_FIELD = , "packager.domain": $(PACKAGER_DOMAIN)
endif

ifdef PACKAGER_COUNTRY_
  PACKAGER_COUNTRY_FIELD = , "packager.country": $(PACKAGER_COUNTRY)
endif

ifdef PACKAGER_STATE
  PACKAGER_STATE_FIELD = , "packager.state": $(PACKAGER_STATE)
endif

ifdef PACKAGER_LOCALITY
  PACKAGER_LOCALITY_FIELD = , "packager.locality": $(PACKAGER_LOCALITY)
endif

ifdef PACKAGER_ORGANIZATION
  PACKAGER_ORGANIZATION_FIELD = , "packager.organization": $(PACKAGER_ORGANIZATION)
endif

ifdef ACME_EMAIL_ADDRESS
  ACME_EMAIL_ADDRESS_FIELD = , "acme.emailAddress": $(ACME_EMAIL_ADDRESS)
endif

ifdef ACME_DIRECTORY_URL
  ACME_DIRECTORY_URL= , "acme.directoryUrl": $(ACME_DIRECTORY_URL)
endif

ifdef SERVICE_LOAD_BALANCER_SOURCE_RANGES
  SERVICE_LOAD_BALANCER_SOURCE_RANGES_FIELD= , "service.loadBalancerSourceRanges": $(SERVICE_LOAD_BALANCER_SOURCE_RANGES)
endif


APP_PARAMETERS ?= { \
  "name": "$(NAME)", \
  "namespace": "$(NAMESPACE)" \
  $(PACKAGER_DOMAIN_FIELD) \
  $(PACKAGER_COUNTRY_FIELD) \
  $(PACKAGER_STATE_FIELD) \
  $(PACKAGER_LOCALITY_FIELD) \
  $(PACKAGER_ORGANIZATION_FIELD) \
  $(ACME_EMAIL_ADDRESS_FIELD) \
  $(ACME_DIRECTORY_URL_FIELD) \
  $(SERVICE_LOAD_BALANCER_SOURCE_RANGES_FIELD) \
}

# c2d_deployer.Makefile provides the main targets for installing the application.
# It requires several APP_* variables defined above, and thus must be included after.
include ../c2d_deployer.Makefile


# Build tester image
app/build:: .build/$(CHART_NAME)/tester
