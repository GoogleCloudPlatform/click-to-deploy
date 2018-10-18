# About

Source for Google Click to Deploy solutions listed on
Google Cloud Marketplace.

# Disclaimer

This is not an officially supported Google product.

# Git submodules

This repository uses [git submodule](https://git-scm.com/docs/git-submodule).
Please run following commands to receive newest version of used modules.

## Updating git submodules

You can use make to make sure submodules
are populated with proper code.

```shell
make submodule/init # or make submodule/init-force
```

Alternatively, you can invoke these commands directly in shell, without `make`.

```shell
git submodule init
git submodule sync --recursive
git submodule update --recursive --init
```

test
