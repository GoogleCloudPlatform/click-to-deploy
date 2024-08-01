# Copyright 2024 Google LLC
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

ENV['DEBIAN_FRONTEND'] = 'noninteractive'

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'php74'
include_recipe 'php74::module_dom'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_libapache2'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_mysql'
include_recipe 'mysql::version-8.0-embedded'
include_recipe 'piwik::ospo'

remote_file 'download_matomo' do
  path '/tmp/matomo.tar.gz'
  source 'https://builds.matomo.org/matomo.tar.gz'
  owner 'root'
  group 'root'
  mode '0640'
  action :create
end

execute 'untar_matomo_tar ' do
  cwd '/tmp'
  command 'tar xzf matomo.tar.gz -C /var/www/html --strip-components 1'
end

# Preparing Piwik
bash 'configure_piwik_for_first_use' do
  user 'root'
  code <<-EOH
    rm -Rf /var/www/html/plugins/Morpheus/icons/submodules
    mkdir /var/www/html/tmp/assets
    chmod -R 0755 /var/www/html/tmp/assets
    mkdir /var/www/html/tmp/cache
    chmod -R 0755 /var/www/html/tmp/cache
    mkdir /var/www/html/tmp/logs
    chmod -R 0755 /var/www/html/tmp/logs
    mkdir /var/www/html/tmp/tcpdf
    chmod -R 0755 /var/www/html/tmp/tcpdf
    mkdir /var/www/html/tmp/templates_c
    chmod -R 0755 /var/www/html/tmp/templates_c
    mkdir /var/www/html/tmp/cache/tracker/
    chmod -R 0755 /var/www/html/tmp/cache/tracker/
    chown -R www-data:www-data /var/www/html
EOH
end

# Remove ExampleUI plugin having icons with license telling that they are free
# for non-commercial use only.
directory 'remove_exampleui_plugin' do
  path '/var/www/html/plugins/ExampleUI'
  recursive true
  action :delete
end

bash 'prepare_database_configuration' do
  user 'root'
  code <<-EOH
    mysql -u root -e "CREATE USER '$user'@'localhost' IDENTIFIED BY '$pass'"
    mysql -u root -e "CREATE DATABASE $dbname CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci"
    mysql -u root -e "GRANT ALL PRIVILEGES ON $dbname.* TO '$user'@'localhost'"
    mysql -u root -e "FLUSH PRIVILEGES"
EOH
  flags '-eu'
  environment({
    'user' => node['matomo']['db']['username'],
    'pass' => node['matomo']['db']['password'],
    'dbname' => node['matomo']['db']['name'],
  })
end

template '/etc/apache2/sites-available/piwik.conf' do
  source 'piwik.conf.erb'
end

execute 'a2ensite piwik'

service 'apache2' do
  action :restart
end

c2d_startup_script 'piwik' do
  source 'piwik.erb'
  action :template
end
