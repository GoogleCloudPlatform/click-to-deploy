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

include_recipe 'apache2'
include_recipe 'apache2::security-config'
include_recipe 'apache2::rm-index'
include_recipe 'mysql'
include_recipe 'php7'
include_recipe 'php7::module_libapache2'
include_recipe 'php7::module_mysql'
include_recipe 'php7::module_xml'

remote_file '/tmp/wp-cli.phar' do
  source node['wordpress']['cli']['url']
  action :create
end

# Reference: http://wp-cli.org/#installing
bash 'configure wp cli' do
  cwd '/tmp'
  code <<-EOH
    # Change permissions on the wp-cli.phar file for manipulation
    chmod +x wp-cli.phar

    # Move wp-cli.phar to complete installation
    mv wp-cli.phar /usr/local/bin/wp
EOH
end

execute 'download wordpress' do
  cwd '/var/www/html'
  command <<-EOH
    wp core download \
      --version=${version} \
      --path=/var/www/html \
      --allow-root
EOH
  environment({ 'version' => node['wordpress']['version'] })
  live_stream true
end

execute 'chown wordpress home' do
  command 'chown -R ${user}:${user} /var/www/html'
  environment({ 'user' => node['wordpress']['user'] })
end

execute 'create wordpress database' do
  command 'mysql -u root -e "CREATE DATABASE ${dbname}"'
  environment({ 'dbname' => node['wordpress']['db']['name'] })
end

execute 'a2enmods' do
  command 'a2enmod rewrite proxy_fcgi setenvif'
end

execute 'a2enconfs' do
  command 'a2enconf php7.0-fpm'
end

template '/etc/apache2/sites-available/wordpress.conf' do
  source 'wordpress.conf.erb'
end

execute 'enable wordpress.conf' do
  command 'a2ensite wordpress'
end

bash 'edit php.ini' do
  user 'root'
  code <<-EOH
    sed -i 's/memory_limit = .*/memory_limit = 128M/' /etc/php/*/apache2/php.ini
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 100M/' /etc/php/*/apache2/php.ini
    sed -i 's/post_max_size = .*/post_max_size = 100M/' /etc/php/*/apache2/php.ini
    sed -i 's/max_execution_time = .*/max_execution_time = 120/' /etc/php/*/apache2/php.ini
EOH
end
