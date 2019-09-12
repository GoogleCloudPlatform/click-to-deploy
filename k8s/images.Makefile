# Gets first argv as image to resolve full path of image with sha256 hash sum.
get_sha256 = $(shell docker pull $1 2>&1 > /dev/null \
&& docker inspect --format='{{ index .RepoDigests 0 }}' $1)

# Gets first argv as image and second as variable to get from container.
get_var_from_container = $(shell docker pull $1 2>&1 > /dev/null \
&& docker run --rm --entrypoint=printenv $1 $2)

# Gets first argv as image and try to get C2D_RELEASE from container.
get_c2d_release = $(call get_var_from_container, $1, C2D_RELEASE)
