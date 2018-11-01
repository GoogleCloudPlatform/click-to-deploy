ifndef __VAR_MAKEFILE__

__VAR_MAKEFILE__ := included

# Provides a class of targets that ensures variables are
# defined and trigger rebuilds when variable values change.
#
# Usage:
#
# my_target: .build/var/REGISTRY
#
#     my_target rebuilds when the value of $(REGISTRY) changes.
#     .build/var/REGISTRY also ensures that $(REGISTRY) value
#     is non-empty.


# The main target that this Makefile offers.
# This is a real file that gets updated when a variable value
# change is detected. This rule does not have a recipe. It
# relies on the %-phony prerequisite to detect the change and
# update the file.
.build/var/%: .build/var/%-required .build/var/%-phony ;


.build/var:
	mkdir -p .build/var


# Since we can't make pattern targets phony, we make them
# effectively phony by depending on this phony target.
.PHONY: var/phony
var/phony: ;


# An effectively phony target that always runs to compare the current
# value of the variable (say VARNAME) with the content of the
# corresponding .build/var/VARNAME file. If the contents differ,
# the recipe updates .build/var/VARNAME, which effectively trigger
# rebuilding of targets depending on .build/var.VARNAME.
.build/var/%-phony: var/phony | .build/var
	@ \
	var_key="$*" ; \
	var_val="${$*}" ; \
	var_val_old=$$(cat ".build/var/$$var_key" 2> /dev/null) ; \
	if [ "$$var_val" != "$$var_val_old" ]; then \
	  $(call print_notice,$$var_key has been updated) ; \
	  printf "  old value: $$var_val_old\n" ; \
	  printf "  new value: $$var_val\n" ; \
	  printf "$$var_val" > .build/var/$$var_key ; \
	fi


# An effectively phony target that verifies that the variable
# has a non-empty value.
.build/var/%-required: var/phony
	@ \
	var_key="$*" ; \
	var_val="${$*}" ; \
	if [ "$$var_val" = "" ]; then \
	  $(call print_notice,Make variable '$*' is required); \
	  exit 1; \
	fi


endif
