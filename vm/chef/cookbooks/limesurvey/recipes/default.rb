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
# - https://manual.limesurvey.org/Installation_-_LimeSurvey_CE
# - https://manual.limesurvey.org/Installation_using_a_command_line_interface_(CLI)

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql'

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
include_recipe 'composer'
include_recipe 'git'

apt_update do
  action :update
end

package 'Install Packages' do
  package_name node['limesurvey']['packages']
  action :install
end

remote_file '/tmp/drupal.tar.gz' do
  source 'https://www.drupal.org/download-latest/tar.gz'
  action :create
end

# execute 'extract drupal' do
#   cwd '/tmp'
#   command 'tar -xf drupal.tar.gz -C /var/www/html --strip-components 1'
# end

# # Clone Limesurvey source code per license requirements.
# git '/usr/src/opencart' do
#   repository 'https://github.com/opencart/opencart.git'
#   reference node['opencart']['version']
#   action :checkout
# end

# bash 'Configure Database' do
#   user 'root'
#   cwd '/var/www/html'
#   code <<-EOH
# # create db
# mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8 COLLATE utf8_general_ci";
# EOH
#   environment({
#     'defdb' => node['opencart']['db']['name'],
#   })
# end

# # Copy the utils file for opencart startup
# cookbook_file '/opt/c2d/opencart-utils' do
#   source 'opencart-utils'
#   owner 'root'
#   group 'root'
#   mode 0644
#   action :create
# end

# apache2_allow_override 'Allow override' do
#   directory '/var/www/html'
# end

# execute 'enable apache modules' do
#   command 'a2enmod rewrite'
# end

c2d_startup_script 'limesurvey'
