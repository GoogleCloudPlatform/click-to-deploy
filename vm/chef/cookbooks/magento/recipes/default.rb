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

include_recipe 'apache2::mod-rewrite'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'php7'
include_recipe 'php7::composer'
include_recipe 'php7::module_libapache2'
include_recipe 'php7::module_mysql'
include_recipe 'mysql'
include_recipe 'composer'

package 'install_dependencies' do
  package_name node['magento']['packages']['dependencies']
  action :install
end

execute 'create magento database' do
  command "mysql -u root -e 'CREATE DATABASE #{node['magento']['db']['name']}'"
end

c2d_startup_script 'magento'
c2d_startup_script 'magento-setup'
c2d_startup_script 'magento-post-setup'
c2d_startup_script 'magento-config-redis'

remote_file '/tmp/magento2.tar.gz' do
  source "https://api.github.com/repos/magento/magento2/tarball/#{node['magento']['version']}"
  action :create
end

bash 'configure magento' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
tar -xf /tmp/magento2.tar.gz --strip-components 1

composer install

find var vendor pub/static pub/media app/etc -type f -exec chmod g+w {} \;
find var vendor pub/static pub/media app/etc -type d -exec chmod g+ws {} \;
chown -R :$user .
chmod u+x bin/magento
EOH
  environment({ 'user' => node['magento']['user'] })
end

execute 'configure php' do
  command "sed -i '/^;always_populate_raw_post_data = -1$/s/;//' /etc/php/7.0/fpm/php.ini"
end

template '/etc/apache2/sites-available/magento.conf' do
  source 'magento.conf.erb'
end

execute 'enable magento.conf' do
  command 'a2ensite magento.conf'
end

execute 'enable proxy_fcgi' do
  command 'a2enmod proxy_fcgi setenvif'
end

execute 'enable php7.0-fpm' do
  command 'a2enconf php7.0-fpm'
end
