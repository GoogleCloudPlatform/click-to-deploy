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
#
# References:
#   https://pimcore.com/docs/pimcore/current/Development_Documentation/Getting_Started/Installation.html
#   https://pimcore.com/docs/pimcore/current/Development_Documentation/Installation_and_Upgrade/System_Requirements.html

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql::version-8.0'

include_recipe 'php80'
include_recipe 'php80::module_curl'
include_recipe 'php80::module_gd'
include_recipe 'php80::module_intl'
include_recipe 'php80::module_libapache2'
include_recipe 'php80::module_mbstring'
include_recipe 'php80::module_mysql'
include_recipe 'php80::module_opcache'
include_recipe 'php80::module_xml'
include_recipe 'php80::module_zip'
include_recipe 'composer::composer-only'
include_recipe 'git'

apt_update do
  action :update
end

package 'Install Dependencies Packages' do
  package_name node['pimcore']['packages']
  action :install
end

git '/usr/src/pimcore' do
  repository 'https://github.com/pimcore/pimcore.git'
  reference "v#{node['pimcore']['version']}"
  action :checkout
end

bash 'Configure Database' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
# create db
mysql -u root -e "CREATE DATABASE $dbname CHARACTER SET utf8 COLLATE utf8_general_ci";
EOH
  environment({
    'dbname' => node['pimcore']['db']['name'],
  })
end

# # Copy the utils file for opencart startup
# cookbook_file '/opt/c2d/opencart-utils' do
#   source 'opencart-utils'
#   owner 'root'
#   group 'root'
#   mode 0644
#   action :create
# end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

c2d_startup_script 'pimcore'
