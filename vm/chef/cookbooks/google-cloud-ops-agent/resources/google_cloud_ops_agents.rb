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

# To learn more about Custom Resources, see https://docs.chef.io/custom_resources/
# Use upgrade because it'll fall back to install if software isn't installed already
# By using upgrade as the default action, if the admin changes the version attribute,
# then the software will update. If this was set to just install, changing the version
# attribute would not result in servers being upgraded.
default_action :upgrade
resource_name :google_cloud_ops_agents
provides :google_cloud_ops_agents
unified_mode true

# Install software, at the specified version
action :install do
  case node['platform_family']
  when 'rhel', 'debian', 'suse', 'amazon'
    bash node['file_url_name'] do
      cwd node['tmp_file_path']
      code "./#{node['file_url_name']} --also-install --version=#{node['version']}"
      only_if "./#{node['file_url_name']} --also-install --version=#{node['version']} --dry-run | grep -qi 'installation succeeded'" == 0
      user 'root'
    end
    case node['agent_type']
    when 'ops-agent'
      servicename = 'google-cloud-ops-agent'
    when 'monitoring'
      servicename = 'stackdriver-agent'
    when 'logging'
      servicename = 'google-fluentd'
    end
    service servicename do
      action [:start, :enable]
      # TODO: When CINC fixes the bug related to this, uncomment the below line
      # user 'root'
    end
    # The user parameter for service isn't working, hack to bypass
    # TODO: once the service command above has the bug fixed and can
    # specify user properly, remove this.
    bash 'hack service' do
      user 'root'
      code "systemctl enable #{servicename}"
    end
  when 'windows'
    powershell_script node['file_url_name'] do
      cwd node['tmp_file_path']
      code "#{node['tmp_file_path']}/#{node['file_url_name']} -AlsoInstall -Version #{node['version']}"
      only_if "#{node['file_url_name']} -AlsoInstall -Version #{node['version']} -WhatIf | findstr /i \"Verification of google-cloud-ops-agent.x86_64.${version} completed\"" == 0
    end
  end
end

# Upgrade software to the specified version, or install if it software
# isn't already present.
action :upgrade do
  case node['platform_family']
  when 'rhel', 'debian', 'suse', 'amazon'
    bash node['file_url_name'] do
      cwd node['tmp_file_path']
      code "./#{node['file_url_name']} --also-install --version=#{node['version']}"
      only_if "./#{node['file_url_name']} --also-install --version=#{node['version']} --dry-run | grep -qi 'installation succeeded'" == 0
      user 'root'
    end
    case node['agent_type']
    when 'ops-agent'
      servicename = 'google-cloud-ops-agent'
    when 'monitoring'
      servicename = 'stackdriver-agent'
    when 'logging'
      servicename = 'google-fluentd'
    end
    service servicename do
      action [:start, :enable]
      # TODO: When CINC fixes the bug related to this, uncomment the below line
      # user 'root'
    end
    # The user parameter for service isn't working, hack to bypass
    # TODO: once the service command above has the bug fixed and can
    # specify user properly, remove this.
    bash 'hack service' do
      user 'root'
      code "systemctl enable #{servicename}"
    end
  when 'windows'
    powershell_script node['file_url_name'] do
      cwd node['tmp_file_path']
      code "#{node['tmp_file_path']}/#{node['file_url_name']} -AlsoInstall -Version #{node['version']}"
      only_if "#{node['file_url_name']} -AlsoInstall -Version #{node['version']} -WhatIf | findstr /i \"Verification of google-cloud-ops-agent.x86_64.${version} completed\"" == 0
    end
  end
end

# Uninstall the software, and remove the repository
action :uninstall do
  # Run the appropriate uninstaller
  case node['platform_family']
  when 'rhel', 'debian', 'suse', 'amazon'
    bash node['file_url_name'] do
      cwd node['tmp_file_path']
      code "./#{node['file_url_name']} --uninstall --remove-repo"
      only_if "./#{node['file_url_name']} --uninstall --remove-repo --dry-run | grep -qi 'uninstallation succeeded'" == 0
      unless node['file_url_name'].include? 'ops-agent'
        action :nothing
      end
      user 'root'
      notifies :run, 'bash[daemon-reload]', :immediately
    end
    # Script does not stop logging or monitoring services
    # So we must do it manually
    case node['agent_type']
    when 'ops-agent'
      servicename = 'google-cloud-ops-agent'
    when 'monitoring'
      servicename = 'stackdriver-agent'
    when 'logging'
      servicename = 'google-fluentd'
    end
    service servicename do
      action :disable
      # TODO: When CINC fixes the bug related to this, uncomment the below line
      # user 'root'
    end
    service servicename do
      action :stop
      notifies :run, "bash[#{node['file_url_name']}]", :immediately
      # TODO: When CINC fixes the bug related to this, uncomment the below line
      # user 'root'
    end
    bash 'daemon-reload' do
      code 'systemctl daemon-reload && systemctl reset-failed'
      user 'root'
      action :nothing
    end
    # Uninstall is not properly removing these files, so we do it here
    if node['agent_type'] == 'monitoring'
      svc_file = '/etc/rc.d/init.d/stackdriver-agent'
      unit_file = '/run/systemd/generator.late/stackdriver-agent.service'
    elsif node['agent_type'] == 'logging'
      svc_file = '/etc/rc.d/init.d/google-fluentd'
      unit_file = '/run/systemd/generator.late/google-fluentd.service'
    end
    unless svc_file.nil? || unit_file.nil?
      file svc_file do
        action :delete
        only_if { ::File.exist?(svc_file) }
      end
      file unit_file do
        action :delete
        only_if { ::File.exist?(unit_file) }
      end
    end
  when 'windows'
    powershell_script node['file_url_name'] do
      cwd node['tmp_file_path']
      code "#{node['tmp_file_path']}/#{node['file_url_name']} -Uninstall -RemoveRepo -Version #{node['version']}"
      only_if "#{node['file_url_name']} -Uninstall -RemoveRepo -Version #{node['version']} -WhatIf | findstr /i \"Verification of google-cloud-ops-agent.x86_64.${version} completed\"" == 0
    end
  end
end

# Download the file(s) needed to install the software
action :download do
  # Create the temp directory if it doesn't exist
  directory node['tmp_file_path'] do
    unless platform_family?('windows')
      owner 'root'
      group 'root'
    end
    mode '0777'
    action :create
  end

  # Download our target file
  remote_file 'Download Installer Script' do
    source node['file_url']
    mode '0755'
    action :create
    path "#{node['tmp_file_path']}/#{node['file_url_name']}"
  end
end
