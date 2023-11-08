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

include_recipe 'php74'
include_recipe 'php74::composer'
include_recipe 'php74::module_libapache2'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_xml'
include_recipe 'php74::module_xmlrpc'
include_recipe 'php74::module_curl'
include_recipe 'php74::module_intl'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_json'
include_recipe 'php74::module_soap'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_cli'
include_recipe 'php74::module_zip'
include_recipe 'composer::composer1'

include_recipe 'apache2'
include_recipe 'apache2::ipv4-listen'
include_recipe 'apache2::mod-rewrite'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

include_recipe 'mysql::version-8.0-embedded'

# Restart Apache2 to have php modules enabled and active.
service 'apache2' do
  action [ :enable, :restart ]
end

apt_update do
  action :update
end

bash 'php configuration' do
  user 'root'
  code <<-EOH
    sed -i 's/^memory_limit = 128M/memory_limit = 512M/' /etc/php/7.4/apache2/php.ini
    sed -i 's/^short_open_tag = Off/short_open_tag = On/' /etc/php/7.4/apache2/php.ini
    sed -i 's/^upload_max_filesize = 2M/upload_max_filesize = 128M/' /etc/php/7.4/apache2/php.ini
    sed -i 's/^max_execution_time = 30/max_execution_time = 360/' /etc/php/7.4/apache2/php.ini
    sed -i 's/^;date.timezone =/date.timezone = UTC/' /etc/php/7.4/apache2/php.ini
    a2enmod rewrite
  EOH
end

remote_file '/tmp/dolibarr.tar.gz' do
  source "https://github.com/Dolibarr/dolibarr/archive/refs/tags/#{node['dolibarr']['version']}.tar.gz"
  verify "echo '#{node['dolibarr']['sha256']} %{path}' | sha256sum -c"
  action :create
end

bash 'install dolibarr' do
  user 'root'
  cwd '/tmp'
  code <<-EOH

    # Extract to /var/www/html and skip moodle directory
    tar -xf dolibarr.tar.gz -C /var/www/html --strip-components 1
    chown -R $user:$user /var/www/html/
    chmod -R 755 /var/www/html/

    # Create conf.php file required for install wizard
    touch /var/www/html/htdocs/conf/conf.php
    chown $user /var/www/html/htdocs/conf/conf.php

    mkdir -p /var/lib/dolibarr/documents
    chmod -R 700 /var/lib/dolibarr/documents
    chown -R $user:$user /var/lib/dolibarr

  EOH
  environment({
    'user' => node['dolibarr']['linux']['user'],
  })
end

template '/etc/apache2/sites-available/000-default.conf' do
  source 'default-apache.erb'
end

bash 'install requirements' do
  user 'root'
  cwd '/var/www/html/'
  code <<-EOH
    composer install
    chown -R ${user}:${user} ..
  EOH
  environment({
    'user' => node['dolibarr']['linux']['user'],
  })
end

template '/var/www/html/htdocs/install/install.forced.php' do
  source 'install.forced.php.erb'
end

bash 'MySQL configuration' do
  user 'root'
  code 'mysql -u root -e "CREATE DATABASE ${default_db} CHARACTER SET utf8 COLLATE utf8_general_ci"'
  environment({
    'default_db' => node['dolibarr']['db']['name'],
  })
end

c2d_startup_script 'dolibarr-db-setup'

c2d_startup_script 'dolibarr-setup-wizard'
