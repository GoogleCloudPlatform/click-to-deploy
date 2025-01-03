# Copyright 2024 Google LLC
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
#
# Reference: https://wiki.dreamfactory.com/DreamFactory/Installation

include_recipe 'mysql::version-8.0-embedded'
include_recipe 'nginx'
include_recipe 'redis::standalone'

include_recipe 'php81'
include_recipe 'php81::module_bcmath'
include_recipe 'php81::module_cli'
include_recipe 'php81::module_dev'
include_recipe 'php81::module_curl'
include_recipe 'php81::module_fpm'
include_recipe 'php81::module_http'
include_recipe 'php81::module_interbase'
include_recipe 'php81::module_ldap'
include_recipe 'php81::module_mbstring'
include_recipe 'php81::module_mongodb'
include_recipe 'php81::module_mysql'
include_recipe 'php81::module_odbc'
include_recipe 'php81::module_opcache'
include_recipe 'php81::module_pdo'
include_recipe 'php81::module_raphf'
include_recipe 'php81::module_soap'
include_recipe 'php81::module_sqlite'
include_recipe 'php81::module_simplexml'
include_recipe 'php81::module_sybase'
include_recipe 'php81::module_xml'
include_recipe 'php81::module_zip'
include_recipe 'composer::composer2'
include_recipe 'git'

include_recipe 'c2d-config::create-self-signed-certificate'

apt_update do
  action :update
end

package 'install_packages' do
  package_name node['dreamfactory']['packages']
  action :install
end

bash 'Install Pear Packages' do
  user 'root'
  code <<-EOH
  DEBIAN_FRONTEND=noninteractive pecl channel-update pecl.php.net && \
    echo '' | pecl install --force mcrypt && \
    echo '' | pecl install --force igbinary && \
    echo '' | pecl install --force sqlsrv-5.11.1 && \
    echo '' | pecl install --force pdo_sqlsrv-5.11.1
EOH
end

cookbook_file '/etc/nginx/sites-available/dreamfactory.conf' do
  source 'nginx-dreamfactory.conf'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

git '/usr/src/dreamfactory' do
  repository 'https://github.com/dreamfactorysoftware/dreamfactory.git'
  reference node['dreamfactory']['version']
  action :checkout
end

bash 'Copy DreamFactory to the production folder' do
  user 'root'
  code <<-EOH
    cp -rf /usr/src/dreamfactory/ /opt/
EOH
end

# Copy and install the front end
cookbook_file '/opt/c2d/setup-frontend' do
  source 'setup-frontend'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

execute 'install_frontend' do
  command '/opt/c2d/setup-frontend'
end

cookbook_file '/opt/c2d/dreamfactory-utils' do
  source 'dreamfactory-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

c2d_startup_script 'dreamfactory'
