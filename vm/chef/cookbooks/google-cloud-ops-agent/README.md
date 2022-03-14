google-cloud-ops-agent
============

# Upstream

This source repo was originally copied from:
https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chefs

# Disclaimer

This is not an official Google product.

# <a name="about"></a>About

Chef cookbook for [Google Cloud Operations agents](https://cloud.google.com/stackdriver/docs/solutions/agents).

For more information, see the [Official Image Marketplace Page](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/blob/master/README.md).

# <a name="table-of-contents"></a>Table of Contents
* [Cloning Cookbook](#cloning-cookbook)
* [Usage](#usage)
* [Version](#version)

# <a name="cloning-cookbook"></a>Cloning Cookbook
To clone the cookbook from your repo to your workstation's chef/cookbooks folder, please use:
`git clone git@github.com:GoogleCloudPlatform/google-cloud-ops-agents-chef.git google_cloud_ops_agents_chef`
from within the cookbooks folder itself.

# <a name="usage"></a>Usage
| Attribute               | Default       | Description                                                       |
| ---                     | ---           | ---                                                               |
| `agent_type`            | Required      | The agent type: `ops-agent`, `monitoring`, `logging`              |
| `package_state`         | `present`     | Boolean value. Ensure that the agent is `present` or `absent`  |
| `version`               | `latest`      | The version variable can be used to specify which version of the agent to install. The allowed values are `latest`, `MAJOR_VERSION.*.*` and `MAJOR_VERSION.MINOR_VERSION.PATCH_VERSION`, which are described in detail below. |
| `main_config`           |               | Optional value for overriding the default configuration           |
| `additional_config_dir` |               | Optional value for overriding the plugins directory for the `monitoring` or `logging` agents |

# <a name="version"></a>Version
- version=`latest`
  - This setting makes it easier to keep the agent version up to date, however it does come with a potential risk. When a new major version is released, the policy may install the latest version of the agent from the new major release, which may introduce breaking changes. For production environments, consider using the version=`MAJOR_VERSION.*.*` setting below for safer agent deployments.

- version=`MAJOR_VERSION.*.*`
  - When a new major release is out, this setting ensures that only the latest version from the specified major version is installed, which avoids accidentally introducing breaking changes. This is recommended for production environments to ensure safer agent deployments.

- version=`MAJOR_VERSION.MINOR_VERSION.PATCH_VERSION`
  - This setting is not recommended since it prevents upgrades of new versions of the agent that include bug fixes and other improvements.
