# Get first argv as image to resovl full path of image with sha256 hash sum
get_sha256 = $(eval SHELLOUT := $(shell docker pull $1 2>&1 > /dev/null \
&& docker inspect --format='{{ index .RepoDigests 0 }}' $1))$(if $(filter-out $(.SHELLSTATUS), 0), \
$(error ERROR: found during get_sha256 hash for "$1": "$(SHELLOUT)" Exit code: $(.SHELLSTATUS) ),$(SHELLOUT))

# Get first argv as image and second as variable to get from container
get_var_from_container = $(eval SHELLOUT := $(shell docker pull $1 2>&1 > /dev/null \
&& docker run --rm --entrypoint=printenv $1 $2))$(if $(filter-out $(.SHELLSTATUS), 0), \
$(error ERROR: found during get $2 variable from "$1": "$(SHELLOUT)" Exit code: $(.SHELLSTATUS) ),$(SHELLOUT))$

# Get first argv as image and try to get C2D_RELEASE from container
get_c2d_release = $(eval SHELLOUT := $(shell docker pull $1 2>&1 > /dev/null \
&& docker run --rm --entrypoint=printenv $1 C2D_RELEASE))$(if $(filter-out $(.SHELLSTATUS), 0), \
$(error ERROR: found during get C2D_RELEASE variable from "$1": "$(SHELLOUT)" Exit code: $(.SHELLSTATUS) ),$(SHELLOUT))$

