# Copyright 2021 Google LLC
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

include_recipe 'nginx'
include_recipe 'mysql'
include_recipe 'php74'
include_recipe 'php74::module_bcmath'
include_recipe 'php74::module_curl'
include_recipe 'php74::module_dom'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_json'
include_recipe 'php74::module_ldap'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_opcache'
include_recipe 'php74::module_soap'
include_recipe 'php74::module_xml'
include_recipe 'php74::module_zip'
include_recipe 'composer'
include_recipe 'git'
include_recipe 'c2d-config::create-self-signed-certificate'

apt_update do
  action :update
end

package 'Install Packages' do
  package_name node['testlink']['packages']
  action :install
end

remote_file '/tmp/testlink.tar.gz' do
  source "https://github.com/TestLinkOpenSourceTRMS/testlink-code/archive/#{node['testlink']['version']}.tar.gz"
  action :create
end

bash 'Extract Testlink' do
  user 'root'
  cwd '/'
  code <<-EOH
  # Copy to src folder due license requirements
  mkdir -p /usr/src/testlink
  tar -xf /tmp/testlink.tar.gz -C /usr/src/testlink --strip-components 1

  # Create a copy for running the application
  mkdir -p /opt/testlink
  cp -rf /usr/src/testlink /opt
EOH
end

bash 'Prepare permissions' do
  user 'root'
  cwd '/opt/testlink'
  code <<-EOH
  mkdir -p /var/testlink/logs/
  mkdir -p /var/testlink/upload_area/
  chmod 640 -R gui/templates_c/
  chmod 640 -R /var/testlink/logs/
  chmod 640 -R /var/testlink/upload_area/
  chown -R www-data:www-data /opt/testlink/
  chown -R www-data:www-data /var/testlink/logs/
  chown -R www-data:www-data /var/testlink/upload_area/
EOH
end

cookbook_file '/etc/nginx/sites-available/testlink.conf' do
  source 'nginx-testlink.conf'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

c2d_startup_script 'testlink'
