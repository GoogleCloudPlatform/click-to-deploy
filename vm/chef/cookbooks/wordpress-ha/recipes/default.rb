# Copyright 2022 Google LLC
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
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql::configure-apt-repo-version-5.7'
include_recipe 'php74'
include_recipe 'php74::module_libapache2'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_xml'

apt_update do
  action :update
end

package node['wordpress-ha']['packages'] do
  action :install
end

package node['wordpress-ha']['temp_packages'] do
  action :install
end

remote_file '/tmp/wp-cli.phar' do
  source node['wordpress-ha']['cli']['url']
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
  environment({ 'version' => node['wordpress-ha']['version'] })
  live_stream true
end

remote_file '/tmp/wp-stateless.zip' do
  source "https://downloads.wordpress.org/plugin/wp-stateless.#{node['wordpress-ha']['wp-stateless']['version']}.zip"
  action :create
end

execute 'unzip wp-stateless' do
  user 'root'
  cwd '/tmp'
  command <<-EOH
    unzip -q /tmp/wp-stateless.zip -d /opt/c2d/downloads
EOH
end

execute 'chown wordpress home' do
  command 'chown -R ${user}:${user} /var/www/html'
  environment({ 'user' => node['wordpress-ha']['user'] })
end

execute 'a2enmods' do
  command 'a2enmod rewrite proxy_fcgi setenvif'
end

execute 'a2enconfs' do
  command 'a2enconf php7.4-fpm'
end

template '/etc/apache2/sites-available/wordpress.conf' do
  source 'wordpress.conf.erb'
end

execute 'enable wordpress.conf' do
  command 'a2ensite wordpress'
end

# GCS Sync Setup
cookbook_file '/lib/systemd/system/gcs-sync.service' do
  source 'gcs-sync.service'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/opt/c2d/downloads/gcs-push.sh' do
  source 'gcs-push.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/opt/c2d/downloads/gcs-pull.sh' do
  source 'gcs-pull.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/opt/c2d/downloads/gcs-pull-once.sh' do
  source 'gcs-pull-once.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

cookbook_file '/opt/c2d/downloads/gcs-pull-lib.sh' do
  source 'gcs-pull-lib.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# The sync service will be enabled and started in a startup script, since we
# need to delete one of the push/pull scripts, and rename the one we keep to
# /opt/c2d/downloads/gcs-sync based on what role the VM will be playing

c2d_startup_script 'wordpress-ha-setup'

c2d_startup_script 'load-balancer-check'

package node['wordpress-ha']['temp_packages'] do
  action :purge
end
