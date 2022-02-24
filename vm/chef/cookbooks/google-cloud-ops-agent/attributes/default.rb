# Copyright:: 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# What type of agent? Valid options are 'ops-agent', 'monitoring', and 'logging'
# Default is to install the ops-agent
default['agent_type'] = 'ops-agent'
# Is the agent installed?
# This should be present to have installed, and set absent to not be installed
default['package_state'] = 'present'
# What version to install? Valid options are 'latest', MAJOR_VERSION, MAJOR.MINOR.PATCH as described in the README.md file.
# Should be set to MAJOR.*.* in production environments, as described in the README
# Defaults to latest
default['version'] = 'latest'
# Optional config file parameters.
# See readme for information on these parameters.
default['main_config'] = ''
default['additional_config_dir'] = ''
# Transmute 'ops-agent' to 'google-cloud-ops'
default['final_agent_type'] = node['agent_type'] == 'ops-agent' ? 'google-cloud-ops' : node['agent_type']
# File URL
case node['platform_family']
when 'rhel', 'debian', 'suse', 'amazon', 'fedora'
  default['file_url_name'] = "add-#{node['final_agent_type']}-agent-repo.sh"
  default['tmp_file_path'] = '/tmp'
when 'windows'
  default['file_url_name'] = 'add-google-cloud-ops-agent-repo.ps1'
  default['tmp_file_path'] = 'C:/temp'
end
default['file_url'] = "https://dl.google.com/cloudagents/#{node['file_url_name']}"
