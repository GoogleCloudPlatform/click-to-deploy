.PHONY: submodule/init
submodule/init:
	git submodule init
	git submodule sync --recursive
	git submodule update --init --recursive

.PHONY: submodule/init-force
submodule/init-force:
	git submodule init
	git submodule sync --recursive
	git submodule update --init --recursive --force
