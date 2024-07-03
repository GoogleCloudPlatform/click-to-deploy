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

include_recipe 'mysql::version-8.0-embedded'

include_recipe 'php81'
include_recipe 'php81::default_bullseye'
include_recipe 'php81::module_curl'
include_recipe 'php81::module_gd'
include_recipe 'php81::module_intl'
include_recipe 'php81::module_libapache2'
include_recipe 'php81::module_mbstring'
include_recipe 'php81::module_mysql'
include_recipe 'php81::module_opcache'
include_recipe 'php81::module_xml'
include_recipe 'php81::module_zip'
include_recipe 'composer::composer-only'

include_recipe 'nodenvm'
include_recipe 'nodenvm::node14'

include_recipe 'git'

apt_update do
  action :update
end

package 'Install Dependencies Packages' do
  package_name node['pimcore']['packages']
  action :install
end

# Download source-code for usage and license purposes
git '/usr/src/pimcore' do
  repository 'https://github.com/pimcore/pimcore.git'
  reference "v#{node['pimcore']['version']}"
  action :checkout
end

bash 'Copy pimcore' do
  user 'root'
  code <<-EOH
cp -rf /usr/src/pimcore /opt/pimcore
EOH
end

# Configure initial database
bash 'Configure Database' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
# create db
mysql -u root -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;"
EOH
  environment({
    'dbname' => node['pimcore']['db']['name'],
  })
end

# Copy Pimcore Apache and PHP configuration files
cookbook_file '/opt/c2d/apache-pimcore.conf' do
  source 'apache-pimcore.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# https://github.com/pimcore/pimcore/blob/10.5/doc/Development_Documentation/23_Installation_and_Upgrade/03_System_Setup_and_Hosting/01_Apache_Configuration.md
cookbook_file '/opt/c2d/apache-pimcore-website.htaccess' do
  source 'apache-pimcore-website.htaccess'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/etc/php/8.1/apache2/conf.d/99-pimcore.ini' do
  source 'php-pimcore.ini'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

c2d_startup_script 'pimcore'
