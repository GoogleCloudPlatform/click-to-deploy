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
# Reference: https://docs.espocrm.com/administration/installation/
include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

include_recipe 'mysql::version-8.0-embedded'

include_recipe 'git'

# Reference: https://docs.espocrm.com/administration/server-configuration/
include_recipe 'php74'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_curl'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_json'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_xml'
include_recipe 'php74::module_zip'
include_recipe 'php74::module_libapache2'

apt_update do
  action :update
end

package 'Install Dependencies Packages' do
  package_name node['espocrm']['packages']
  action :install
end

# Clone EspoCRM source code per license requirements.
git '/usr/src/espocrm' do
  repository 'https://github.com/espocrm/espocrm.git'
  reference node['espocrm']['version']
  action :checkout
end

remote_file '/tmp/EspoCRM.zip' do
  source "https://www.espocrm.com/downloads/EspoCRM-#{node['espocrm']['version']}.zip"
  action :create
end

execute 'extract EspoCRM' do
  cwd '/tmp'
  command 'unzip -q EspoCRM.zip && rm EspoCRM.zip && mv EspoCRM-* /opt/espocrm'
end

bash 'Configure Database' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
# create db
mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
EOH
  environment({
    'defdb' => node['espocrm']['db']['name'],
  })
end

bash 'Set required mysqld options for EspoCRM' do
  code <<-EOH
    cat > /etc/my.cnf << 'EOF'
#
# Required mysqld options for EspoCRM
[mysqld]
default-authentication-plugin=mysql_native_password
EOF
EOH
end

# Copy EspoCRM Apache config files
cookbook_file '/opt/c2d/apache-espocrm.conf' do
  source 'apache-espocrm.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# Copy the utils file for EspoCRM startup
cookbook_file '/opt/c2d/espocrm-utils' do
  source 'espocrm-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

c2d_startup_script 'espocrm'
