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
#
# Reference: https://docs.joomla.org/J4.x:Installing_Joomla

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

include_recipe 'git'
include_recipe 'joomla::ospo'

include_recipe 'mysql::version-8.0-embedded'

include_recipe 'php81'
include_recipe 'php81::module_cli'
include_recipe 'php81::module_curl'
include_recipe 'php81::module_gd'
include_recipe 'php81::module_intl'
include_recipe 'php81::module_ldap'
include_recipe 'php81::module_libapache2'
include_recipe 'php81::module_mbstring'
include_recipe 'php81::module_mysql'
include_recipe 'php81::module_xml'
include_recipe 'php81::module_zip'

remote_file '/tmp/joomla.tar.gz' do
  source "https://github.com/joomla/joomla-cms/releases/download/#{node['joomla']['version']}/Joomla_#{node['joomla']['version']}-Stable-Full_Package.tar.gz"
  verify "echo '#{node['joomla']['sha256']} %{path}' | sha256sum -c"
  action :create
end

directory '/opt/joomla' do
  owner 'www-data'
  group 'www-data'
  mode '0755'
  action :create
end

bash 'Extract Joomla' do
  user 'www-data'
  cwd '/tmp'
  code <<-EOH
tar -xf joomla.tar.gz -C /opt/joomla
EOH
end

bash 'Configure Database' do
  user 'root'
  cwd '/opt/joomla'
  code <<-EOH
# create db
mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
EOH
  environment({
    'defdb' => node['joomla']['db']['name'],
  })
end

template '/etc/apache2/sites-available/joomla.conf' do
  source 'joomla.conf.erb'
end

cookbook_file '/etc/php/8.1/apache2/conf.d/99-joomla.ini' do
  source 'php-joomla.ini'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# Copy the utils file for joomla startup
cookbook_file '/opt/c2d/joomla-utils' do
  source 'joomla-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'disable 000-default.conf' do
  command 'a2dissite 000-default'
end

execute 'enable joomla.conf' do
  command 'a2ensite joomla'
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

service 'apache2' do
  action :restart
end

c2d_startup_script 'joomla'
