# Copyright 2018 Google LLC
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
# Reference: http://doc.prestashop.com/display/PS17/Installing+PrestaShop
# CLI Install: http://doc.prestashop.com/display/PS17/Installing+PrestaShop+using+the+command-line+script

node.override['mysql']['bind_address'] = 'localhost'

include_recipe 'apache2::mod-rewrite'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql'
include_recipe 'php72'
include_recipe 'php72::module_curl'
include_recipe 'php72::module_dom'
include_recipe 'php72::module_intl'
include_recipe 'php72::module_libapache2'
include_recipe 'php72::module_mbstring'
include_recipe 'php72::module_mysql'
include_recipe 'php72::module_simplexml'
include_recipe 'php72::module_zip'

package node['prestashop']['temp_packages'] do
  action :install
end

execute 'create prestashop database' do
  command "mysql -u root -e 'CREATE DATABASE #{node['prestashop']['db']['name']}'"
end

# Download prestashop & verify its checksum
remote_file '/tmp/prestashop.zip' do
  source "https://download.prestashop.com/download/releases/prestashop_#{node['prestashop']['version']}.zip"
  action :create
end

bash 'configure_prestashop' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # Create temporary directory
    folder=$(mktemp -d)

    # Unzip prestashop archive to temporary directory
    unzip -q /tmp/prestashop.zip -d $folder

    # Unzip source of prestashop to the final location
    unzip -n -q $folder/prestashop.zip -d /var/www/html/
EOH
end

cookbook_file '/etc/apache2/sites-available/prestashop.conf' do
  source 'prestashop.conf'
end

execute 'enable prestashop.conf' do
  command 'a2ensite prestashop'
end

c2d_startup_script 'prestashop-db-setup' do
  source 'prestashop-db-setup'
  action :cookbook_file
end

c2d_startup_script 'prestashop-install' do
  source 'prestashop-install'
  action :cookbook_file
end

package node['prestashop']['temp_packages'] do
  action :purge
end
