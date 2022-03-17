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

# Validate the agent type
unless %w(ops-agent monitoring logging).include? node['agent_type']
  Chef::Log.fatal("Received invalid agent type: '#{node['agent_type']}'. The Cloud Ops Chef cookbook supports the following agents: 'monitoring', 'logging' and 'ops-agent'.")
end

# For windows, only the ops-agent is supported
if platform_family?('windows') && (%w(monitoring logging).include? node['agent_type'])
  Chef::Log.fatal("The agent type was specified as '#{node['agent_type']}', but only 'ops-agent' is supported on Windows")
end

# Validate the package state
unless %w(present absent).include? node['package_state']
  Chef::Log.fatal("Received invalid package state: '#{node['package_state']}'. The Cloud Ops Chef cookbook supports the following package states: 'present' and 'absent'.")
end

if (%w(ops-agent).include? node['agent_type']) && !node['additional_config_dir'].empty?
  Chef::Log.fatal("The ops agent does not support additional configurations. additional_config_dir must be empty when the agent_type is 'ops-agent'.")
end

# Work out what the OS family is.
# Error for unsupported OS
unless platform_family?('rhel', 'debian', 'suse', 'amazon', 'windows')
  Chef::Log.fatal("Received invalid Operating System Platform Family: '#{node['platform_family']}'. The Cloud Ops Chef cookbook supports the following OSs: Debian, Ubuntu, RedHat,
      CentOS, Amazon, SLES, openSUSE, SuSE, SLES_SAP and Windows via the Chef 'platform_family' attribute.")
end

# If the package_state specifies present, we should be doing install or upgrade
if node['package_state'] == 'present'
  google_cloud_ops_agents 'Download Software' do
    action :download
  end
  google_cloud_ops_agents 'Install Software' do
    action :install
  end

  # Config File and Plugins Dir Variables
  config_path = 'C:/Program Files/Google/Cloud Operations/Ops Agent/config/config.yaml'
  plugins_path = ''
  unless platform_family?('windows')
    if node['agent_type'] == 'ops-agent'
      config_path = '/etc/google-cloud-ops-agent/config.yaml'
    elsif node['agent_type'] == 'monitoring'
      config_path = '/etc/stackdriver/collectd.conf'
      plugins_path = '/etc/stackdriver/collectd.d'
    elsif node['agent_type'] == 'logging'
      config_path = '/etc/google-fluentd/google-fluentd.conf'
      plugins_path = '/etc/google-fluentd/plugin'
    end
  end

  # Main Config File
  # rubocop:disable Metrics/BlockNesting
  unless node['main_config'].empty?
    if node['main_config'].end_with?('.yaml.erb') || node['main_config'].end_with?('.conf.erb')
      # Template
      template config_path do
        source node['main_config']
        unless platform_family?('windows')
          owner 'root'
          group 'root'
          mode '0644'
        end
      end
    elsif node['main_config'].end_with?('.yaml') || node['main_config'].end_with?('.conf')
      # Remote File
      remote_file config_path do
        source node['main_config']
        unless platform_family?('windows')
          owner 'root'
          group 'root'
          mode '0644'
        end
      end
    else
      # Failure due to incorrect file type
      Chef::Log.fatal('The `main_config` attribute was set to an invalid value. It must either be a Chef template or a file ending in .yaml or .conf')
    end
  end

  # Additional config dir for plugins
  unless node['additional_config_dir'].empty?
    # Create the plugins dir if needed
    directory plugins_path do
      action :create
      recursive true
      unless platform_family?('windows')
        owner 'root'
        group 'root'
        mode '0644'
      end
    end
    # Recursively copy the files
    node['additional_config_dir'].split(',').each do |plugin_file|
      Chef::Log.info("Evaluating Plugin File: #{plugin_file} from #{node['additional_config_dir']}")
      remote_file "#{plugins_path}/#{File.basename(plugin_file)}" do
        source "file://#{plugin_file}"
        owner 'root'
        group 'root'
        mode '0644'
      end
    end
  end
# rubocop:enable Metrics/BlockNesting

# If it specifies absent, we should be doing uninstall
elsif node['package_state'] == 'absent'
  google_cloud_ops_agents 'Uninstall Software' do
    action :uninstall
  end
# Otherwise, we need to display an error
else
  Chef::Log.fatal("Unknown option for package_state. Allowed options are 'present' and 'absent'")
end
