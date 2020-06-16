# Copyright 2018 Google LLC
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
# Reference: https://docs.joomla.org/J3.x:Installing_Joomla

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql'

include_recipe 'php74'
include_recipe 'php74::module_cli'
include_recipe 'php74::module_curl'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_intl'
include_recipe 'php74::module_json'
include_recipe 'php74::module_libapache2'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_opcache'
include_recipe 'php74::module_readline'
include_recipe 'php74::module_soap'
include_recipe 'php74::module_xml'
include_recipe 'php74::module_zip'

remote_file '/tmp/joomla.tar.gz' do
  source "https://github.com/joomla/joomla-cms/releases/download/#{node['joomla']['version']}/Joomla_#{node['joomla']['version']}-Stable-Full_Package.tar.gz"
  verify "echo '#{node['joomla']['sha1']} %{path}' | sha1sum -c"
  action :create
end

bash 'configuration' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
# extract to /var/www/html :]
tar -xf joomla.tar.gz -C /var/www/html
chown -R $user:$user /var/www/html/

mysql -u root -e "CREATE DATABASE $defdb"
EOH
  environment({
    'user' => node['joomla']['user'],
    'defdb' => node['joomla']['db']['name'],
  })
end

template '/etc/apache2/sites-available/joomla.conf' do
  source 'joomla.conf.erb'
end

execute 'enable joomla.conf' do
  command 'a2ensite joomla'
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

# Reference: https://docs.joomla.org/Preconfigured_htaccess
execute 'enable .htaccess ' do
  cwd '/var/www/html'
  command 'mv htaccess.txt .htaccess'
end

execute 'enable robots.txt ' do
  cwd '/var/www/html'
  command 'mv robots.txt.dist robots.txt'
end

# Reference: https://forum.joomla.org/viewtopic.php?t=613245
file '/var/www/html/web.config.txt' do
  action :delete
end

bash 'edit php.ini' do
  user 'root'
  code <<-EOH
    sed -i 's/memory_limit = .*/memory_limit = 128M/' /etc/php/*/apache2/php.ini
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 40M/' /etc/php/*/apache2/php.ini
    sed -i 's/post_max_size = .*/post_max_size = 40M/' /etc/php/*/apache2/php.ini
    sed -i 's/max_execution_time = .*/max_execution_time = 120/' /etc/php/*/apache2/php.ini
EOH
end

c2d_startup_script 'joomla' do
  source 'joomla'
  action :cookbook_file
end
