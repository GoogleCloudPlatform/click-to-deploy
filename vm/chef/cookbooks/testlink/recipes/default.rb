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
# ctype
include_recipe 'php74::module_curl'
include_recipe 'php74::module_dom'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_json'
include_recipe 'php74::module_ldap'
include_recipe 'php74::module_libapache2'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_opcache'
include_recipe 'php74::module_soap'
include_recipe 'php74::module_xml'
include_recipe 'php74::module_zip'
include_recipe 'composer'
include_recipe 'git'

# TODO: check it if exts are really required.
# php-mcrypt \
# php-openssl \
# php-gmp \
# php-pdo_odbc \
# php-json \
# php-pdo \
# php-sqlite3 \
# php-apcu \
# php-gd \
# php-xcache \
# php-odbc \
# php-pdo_mysql \
# php-pdo_sqlite \
# php-pgsql \
# php-gettext \
# php-xmlreader \
# php-xmlrpc \
# php-ldap \
# php-bz2 \
# php-memcache \
# php-mssql \
# php-iconv \
# php-pdo_dblib \
# php-curl \
# php-ctype \
# php-fpm && \

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
  mkdir -p logs/
  mkdir -p upload_area/
  chmod 640 -R gui/templates_c/
  chmod 640 -R logs
  chmod 640 -R upload_area
EOH
end

# # Clone OpenCart source code per license requirements.
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

c2d_startup_script 'testlink'
