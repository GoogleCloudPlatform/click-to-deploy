# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

include_recipe 'php81'
include_recipe 'php81::module_libapache2'
include_recipe 'php81::module_simplexml'
include_recipe 'php81::module_xmlrpc'
include_recipe 'php81::module_redis'
include_recipe 'php81::module_mysql'
include_recipe 'php81::module_dom'
include_recipe 'php81::module_zip'
include_recipe 'composer::composer2'
include_recipe 'mautic::ospo'

include_recipe 'git'
include_recipe 'mysql::version-8.0-embedded'

include_recipe 'apache2'
include_recipe 'apache2::ipv4-listen'
include_recipe 'apache2::mod-rewrite'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

include_recipe 'nodejs::default_nodejs16'

package 'Install packages' do
  package_name node['mautic']['packages']
  action :install
end

bash 'php configuration' do
  user 'root'
  code <<-EOH
    sed -i 's/^memory_limit = 128M/memory_limit = 512M/' /etc/php/*/apache2/php.ini
    sed -i 's/^short_open_tag = Off/short_open_tag = On/' /etc/php/*/apache2/php.ini
    sed -i 's/^upload_max_filesize = 2M/upload_max_filesize = 128M/' /etc/php/*/apache2/php.ini
    sed -i 's/^max_execution_time = 30/max_execution_time = 300/' /etc/php/*/apache2/php.ini
    sed -i 's/^;date.timezone =/date.timezone = UTC/' /etc/php/*/apache2/php.ini
    phpenmod imap
  EOH
end

bash 'MySQL configuration' do
  user 'root'
  code 'mysql -u root -e "CREATE DATABASE ${defdb}"'
  environment({
  'defdb' => node['mautic']['db']['name'],
})
end

git '/var/www/html/mautic' do
  repository 'https://github.com/mautic/mautic.git'
  revision node['mautic']['version']
  action :checkout
end

template '/etc/apache2/sites-available/000-default.conf' do
  source 'default-apache.erb'
end

template '/etc/cron.d/mautic' do
  source 'mautic-crontab.erb'
  mode '0644'
end

bash 'install requirements' do
  user 'root'
  cwd '/var/www/html/mautic/'
  code <<-EOH
composer install -n
chown -R ${user}:${user} ../mautic
EOH
  environment({
  'user' => node['mautic']['user'],

})
end

# Download licenses/source code for OSPO
git '/usr/src/device-detector' do
  repository 'https://github.com/matomo-org/device-detector.git'
  action :checkout
end

c2d_startup_script 'mautic'
