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
# References:
# - https://manual.limesurvey.org/Installation_-_LimeSurvey_CE
# - https://manual.limesurvey.org/Installation_using_a_command_line_interface_(CLI)

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql::version-8.0-embedded'

include_recipe 'php74'
include_recipe 'php74::module_curl'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_imap'
include_recipe 'php74::module_json'
include_recipe 'php74::module_ldap'
include_recipe 'php74::module_libapache2'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_opcache'
include_recipe 'php74::module_xml'
include_recipe 'php74::module_zip'
include_recipe 'git'

apt_update do
  action :update
end

remote_file '/tmp/limesurvey.tar.gz' do
  source "https://github.com/LimeSurvey/LimeSurvey/archive/refs/tags/#{node['limesurvey']['version']}.tar.gz"
  action :create
end

execute 'Extract LimeSurvey' do
  cwd '/tmp'
  command 'tar -xf limesurvey.tar.gz -C /var/www/html --strip-components 1'
end

# Clone LimeSurvey source code due license requirements.
git '/usr/src/limesurvey' do
  repository 'https://github.com/LimeSurvey/LimeSurvey.git'
  reference node['limesurvey']['version']
  action :checkout
end

bash 'Configure Database' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
# create db
mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8 COLLATE utf8_general_ci";
EOH
  environment({
    'defdb' => node['limesurvey']['db']['name'],
  })
end

# Copy the utils file for limesurvey startup
cookbook_file '/opt/c2d/limesurvey-utils' do
  source 'limesurvey-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# LimeSurvey configuration template
cookbook_file '/var/www/html/application/config/config.template.php' do
  source 'config.php'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

apache2_allow_override 'Allow override' do
  directory '/var/www/html'
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

c2d_startup_script 'limesurvey'
