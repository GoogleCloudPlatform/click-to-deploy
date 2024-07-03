# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Include default recipe from apache2, postgresql, openjdk8 cookbook.

include_recipe 'c2d-config::default'
include_recipe 'apache2::default'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'postgresql::standalone_bullseye'

package 'install openjdk-17-jdk' do
  package_name 'openjdk-17-jdk'
  action :install
end

package 'install zip' do
  package_name 'zip'
  action :install
end

# Creating sonar user.
user node['sonarqube']['user']

# Downloading sonarqube.
remote_file "sonarqube-#{node['sonarqube']['version']}.zip" do
  source "https://binaries.sonarsource.com/Distribution/sonarqube/sonarqube-#{node['sonarqube']['version']}.zip"
  owner node['sonarqube']['user']
  group node['sonarqube']['user']
  mode '0755'
  action :create
end

bash 'unzip_sonarqube' do
  code <<-EOF
  unzip sonarqube-#{node['sonarqube']['version']}.zip
  rm sonarqube-#{node['sonarqube']['version']}.zip
  mv sonarqube-#{node['sonarqube']['version']} /opt/sonarqube
  chown -R sonar:sonar /opt/sonarqube
  EOF
end

template '/etc/systemd/system/sonar.service' do
  source 'sonar.service.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'enable_apache_modules' do
  command 'a2enmod proxy proxy_http'
end

template '/etc/apache2/sites-available/sonar.conf' do
  source 'sonar.conf.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/security/limits.d/99-sonarqube.conf' do
  source '99-sonarqube.conf.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

template '/etc/sysctl.conf' do
  source 'sysctl.conf.erb'
  action :create
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'enable sonar.conf' do
  command 'a2ensite sonar.conf'
end

execute 'disable 000-defautl.conf' do
  command 'a2dissite 000-default.conf'
end

service 'apache2' do
  action :restart
end

# Clone source code per license requirement.
remote_file "/usr/src/#{node['sonarqube']['version']}.zip" do
  source "https://github.com/SonarSource/sonarqube/archive/#{node['sonarqube']['version']}.zip"
  mode '0644'
  action :create
  retries 5
  retry_delay 30
end

c2d_startup_script 'sonar-config-setup'
