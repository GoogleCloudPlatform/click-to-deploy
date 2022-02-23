# Google Cloud Operations Agents Chef Integration

[![Linux Continuous Integration](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/linux.yml/badge.svg)](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/linux.yml)
[![Windows Continuous Integration](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/windows.yml/badge.svg)](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/windows.yml)
[![Cookstyle](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/cookstyle.yml/badge.svg)](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/cookstyle.yml)
[![Shellcheck](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/shellcheck.yml/badge.svg)](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/shellcheck.yml)
[![License Check](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/license.yml/badge.svg)](https://github.com/GoogleCloudPlatform/google-cloud-ops-agents-chef/actions/workflows/license.yml)

## Description

Chef cookbook for [Google Cloud Operations agents](https://cloud.google.com/stackdriver/docs/solutions/agents).

## Support Matrix

- Linux
  - [Cloud Ops Agent](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent)
    - [Supported Instances](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent#supported_vms)
  - [Monitoring Agent](https://cloud.google.com/stackdriver/docs/solutions/agents/monitoring)
    - [Supported Instances](https://cloud.google.com/stackdriver/docs/solutions/agents/monitoring#supported_vms)
  - [Logging Agent](https://cloud.google.com/stackdriver/docs/solutions/agents/logging)
    - [Supported Instances](https://cloud.google.com/stackdriver/docs/solutions/agents/logging#supported_vms)
- Windows
  - [Cloud Ops Agent](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent)
    - [Supported Instances](https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent#supported_vms)

## Requirements

https://cloud.google.com/stackdriver/docs/solutions/agents/ops-agent#access

## Install Cookbook

### Cloning the Cookbook
To clone the cookbook from your repo to your workstation's chef/cookbooks folder, please use:
`git clone git@github.com:GoogleCloudPlatform/google-cloud-ops-agents-chef.git google_cloud_ops_agents_chef`
from within the cookbooks folder itself.

### Install Cookbook from Source
- Copy to your Chef server
  - `knife cookbook upload google_cloud_ops_agents_chef`
- Verify: `knife cookbook show google_cloud_ops_agents_chef`

## Usage

| Attribute               | Default       | Description                                                       |
| ---                     | ---           | ---                                                               |
| `agent_type`            | Required      | The agent type: `ops-agent`, `monitoring`, `logging`              |
| `package_state`         | `present`     | Boolean value. Ensure that the agent is `present` or `absent`  |
| `version`               | `latest`      | The version variable can be used to specify which version of the agent to install. The allowed values are `latest`, `MAJOR_VERSION.*.*` and `MAJOR_VERSION.MINOR_VERSION.PATCH_VERSION`, which are described in detail below. |
| `main_config`           |               | Optional value for overriding the default configuration           |
| `additional_config_dir` |               | Optional value for overriding the plugins directory for the `monitoring` or `logging` agents |

### Version

- version=`latest`
  - This setting makes it easier to keep the agent version up to date, however it does come with a potential risk. When a new major version is released, the policy may install the latest version of the agent from the new major release, which may introduce breaking changes. For production environments, consider using the version=`MAJOR_VERSION.*.*` setting below for safer agent deployments.

- version=`MAJOR_VERSION.*.*`
  - When a new major release is out, this setting ensures that only the latest version from the specified major version is installed, which avoids accidentally introducing breaking changes. This is recommended for production environments to ensure safer agent deployments.

- version=`MAJOR_VERSION.MINOR_VERSION.PATCH_VERSION`
  - This setting is not recommended since it prevents upgrades of new versions of the agent that include bug fixes and other improvements.

### Example:
Example roles for all below configurations can be found in the examples
folder. Bootstrapping examples defined below for each configuration. Please
see the `attributes/default.rb` file or the above section for more information
on the attributes and their possible values. Their defaults are also
described.

#### Ops Agent
Create a role defining the attributes above, and assign it to the node from
the Chef server or via bootstrap. Bootstrap examples:

- To install the latest Ops Agent with the default configuration, run the following command. This sets `version` to `latest`, `package_state` to `present`, and `agent_type` to `ops-agent`:
  - Linux: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"ops-agent\"}"`
  - Windows: `knife bootstrap -o winrm <windows-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"ops-agent\"}"`

- To install the `2.0.1` version of Ops Agent with the default configuration, run the following command. This sets `version` to `2.0.1`, `package_state` to `present`, and `agent_type` to `ops-agent`:
  - Linux: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"version\": \"2.0.1\"}"`
  - Windows: `knife bootstrap -o winrm <windows-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"version\": \"2.0.1\"}"`

#### Ops Agent with Custom Configuration
In addition to creating a role or bootstrapping as described above, the 
custom configuration files will also need to be created. The optional
parameter main_config will need to be defined in the role or via the
bootstrap -j flag to point to the directory where these custom config files
live. Bootstrap examples:

- To install the latest version of Ops Agent with a custom configuration, run the following command. This sets `version` to `latest`, `package_state` to `present`, `agent_type` to `ops-agent`, and setting the `main_config` file path:
  - Linux: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"main_config\": \"/some/path/to/config/files\"}"`
  - Windows: `knife bootstrap -o winrm <windows-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"main_config\": \"C:/some/path/to/config/files\"}"`

#### Remove Ops Agent
By making use of the package_state attribute in a role passed via the
bootstrap -j flag, with a setting of absent, the Ops Agent can be removed
from the host.

To uninstall the Ops Agent, run the following command. This sets `version` to `latest`, `package_state` to `absent`, and `agent_type` to `ops-agent`
  - Linux: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"package_state\": \"absent\"}"`
  - Windows: `knife bootstrap -o winrm <windows-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"package_state\": \"absent\"}"`

#### Install Monitoring Agent
In order to install the monitoring agent, the role or bootstrap -j needs to
have agent_type set to 'monitoring'. All other options remain as defined
above for the ops_agent. The optional 'additiona_config_dir' parameter can
also be defined to provide additional plugins. This agent is only supported
on Linux. Bootstrap examples:

- To install the latest Monitoring Agent, run the following command. This sets `version` to `latest`, `package_state` to `present`, and `agent_type` to `monitoring`
  - Linux Install: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"monitoring\"}"`
  - Linux Uninstall: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"monitoring\", \"package_state\": \"absent\"}"`
  - Linux Install With Plugins: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"monitoring\", \"additional_config_dir\": \"/some/path\"}"`
  - Linux Uninstall With Plugins: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"monitoring\", \"additional_config_dir\": \"/some/path\", \"package_state\": \"absent\"}"`


#### Install Logging Agent
Management of the logging agent is exactly like that of the monitoring
agent, with the exception of changing the agent_type to 'logging'.
This agent is only supported on Linux. Bootstrap examples:

- To install the Logging Agent, run the following command. This sets `version` to `latest`, `package_state` to `present`, and `agent_type` to `logging`
  - Linux Install: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"logging\"}"`
  - Linux Uninstall: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"logging\", \"package_state\": \"absent\"}"`
  - Linux Install With Plugins: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"logging\", \"additional_config_dir\": \"/some/path\"}"`
  - Linux Uninstall With Plugins: `knife bootstrap <linux-server-fqdn> -r 'google_cloud_ops_agents_chef' -U <username> -P <password> -V -j "{\"agent_type\": \"logging\", \"additional_config_dir\": \"/some/path\", \"package_state\": \"absent\"}"`

## License

```
Copyright 2021 Google Inc. All rights reserved.

Licensed under the Apache License, Version 2.0 (the "License"); you may not use
this file except in compliance with the License.  You may obtain a copy of the
License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software distributed
under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
CONDITIONS OF ANY KIND, either express or implied.  See the License for the
specific language governing permissions and limitations under the License.
```
Additionally a copy of this license has been provided in the [LICENSE](LICENSE) file
