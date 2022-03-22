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

include_recipe 'nginx::embedded'
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
include_recipe 'git'

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

['logs', 'upload_area', 'gui/templates_c'].each do |dir|
  directory "/var/testlink/#{dir}/" do
    owner 'www-data'
    group 'www-data'
    mode '0740'
    recursive true
    action :create
  end
end

bash 'Prepare permissions' do
  user 'root'
  code <<-EOH
  chown -R www-data:www-data /opt/testlink/
EOH
end

cookbook_file '/etc/nginx/sites-enabled/testlink.conf' do
  source 'nginx-testlink.conf'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/testlink-utils' do
  source 'testlink-utils'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

c2d_startup_script 'testlink'
