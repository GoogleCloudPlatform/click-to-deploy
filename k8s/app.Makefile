ifndef __APP_MAKEFILE__

__APP_MAKEFILE__ := included


makefile_dir := $(dir $(realpath $(lastword $(MAKEFILE_LIST))))
include $(makefile_dir)/common.Makefile
include $(makefile_dir)/var.Makefile


# Extracts the name property from APP_PARAMETERS.
define name_parameter
$(shell echo '$(APP_PARAMETERS)' \
    | docker run -i --entrypoint=/bin/print_config.py --rm $(APP_DEPLOYER_IMAGE) --values_mode stdin --xtype NAME)
endef


# Extracts the namespace property from APP_PARAMETERS.
define namespace_parameter
$(shell echo '$(APP_PARAMETERS)' \
    | docker run -i --entrypoint=/bin/print_config.py --rm $(APP_DEPLOYER_IMAGE) --values_mode stdin --xtype NAMESPACE)
endef


# Combines APP_PARAMETERS and APP_TEST_PARAMETERS.
define combined_parameters
$(shell echo '$(APP_PARAMETERS)' '$(APP_TEST_PARAMETERS)' \
    | docker run -i --entrypoint=/usr/bin/jq --rm $(APP_DEPLOYER_IMAGE) -s '.[0] * .[1]')
endef


##### Helper targets #####


.build/app: | .build
	mkdir -p "$@"


# Always update the dev script to make sure it's up to date.
# There isn't currently a way to detect if the dev container has changed.
.PHONY: .build/app/dev
.build/app/dev: .build/var/MARKETPLACE_TOOLS_TAG \
              | .build/app
	docker run \
	    "gcr.io/cloud-marketplace-tools/k8s/dev:$(MARKETPLACE_TOOLS_TAG)" \
	    cat /scripts/dev > "$@"
	chmod a+x "$@"


########### Main  targets ###########


# Builds the application containers and push them to the registry.
# Including Makefile can extend this target. This target is
# a prerequisite for install.
.PHONY: app/build
app/build:: ;


# Installs the application into target namespace on the cluster.
.PHONY: app/install
app/install:: app/build \
              .build/var/APP_DEPLOYER_IMAGE \
              .build/var/APP_PARAMETERS \
              .build/var/MARKETPLACE_TOOLS_TAG \
              | .build/app/dev
	$(call print_target)
	.build/app/dev \
	    /scripts/install \
	        --deployer='$(APP_DEPLOYER_IMAGE)' \
	        --parameters='$(APP_PARAMETERS)' \
	        --entrypoint="/bin/deploy.sh"


# Installs the application into target namespace on the cluster.
.PHONY: app/install-test
app/install-test:: app/build \
                   .build/var/APP_DEPLOYER_IMAGE \
                   .build/var/APP_PARAMETERS \
                   .build/var/APP_TEST_PARAMETERS \
                   .build/var/MARKETPLACE_TOOLS_TAG \
	           | .build/app/dev
	$(call print_target)
	.build/app/dev \
	    /scripts/install \
	        --deployer='$(APP_DEPLOYER_IMAGE)' \
	        --parameters='$(call combined_parameters)' \
	        --entrypoint="/bin/deploy_with_tests.sh"


# Uninstalls the application from the target namespace on the cluster.
.PHONY: app/uninstall
app/uninstall: .build/var/APP_DEPLOYER_IMAGE \
               .build/var/APP_PARAMETERS
	$(call print_target)
	kubectl delete 'application/$(call name_parameter)' \
	    --namespace='$(call namespace_parameter)' \
	    --ignore-not-found


# Runs the verification pipeline.
.PHONY: app/verify
app/verify: app/build \
            .build/var/APP_DEPLOYER_IMAGE \
            .build/var/APP_PARAMETERS \
            .build/var/APP_TEST_PARAMETERS \
            .build/var/MARKETPLACE_TOOLS_TAG \
            | .build/app/dev
	$(call print_target)
	.build/app/dev \
	    /scripts/verify \
	          --deployer='$(APP_DEPLOYER_IMAGE)' \
	          --parameters='$(call combined_parameters)'


# Runs diagnostic tool to make sure your environment is properly setup.
app/doctor: | .build/app/dev
	$(call print_target)
	.build/app/dev /scripts/doctor.py


endif
