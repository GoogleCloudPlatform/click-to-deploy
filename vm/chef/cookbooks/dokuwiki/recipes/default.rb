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

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

package 'install_packages' do
  package_name ['ca-certificates', 'curl']
  retries 5
  retry_delay 30
  action :install
end

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'php81'
include_recipe 'php81::module_libapache2'
include_recipe 'php81::module_xml'
include_recipe 'dokuwiki::ospo'

bash 'Download key' do
  user 'root'
  code <<-EOH
    curl -L -o /usr/share/keyrings/php-sury.org.gpg https://packages.sury.org/php/apt.gpg
EOH
end

# Restart Apache2 to have php modules enabled and active.
service 'apache2' do
  action :restart
end

# Download, untar and mark as owned by www-data all files of DokuWiki.
remote_file '/tmp/dokuwiki.tgz' do
  source "https://github.com/dokuwiki/dokuwiki/releases/download/release-#{node['dokuwiki']['download_version']}/dokuwiki-#{node['dokuwiki']['download_version']}.tgz"
  action :create
end

bash 'untar_dokuwiki_tar' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
    tar xzf /tmp/dokuwiki.tgz -C . --strip-components 1
    chown -R www-data:www-data .
    cp conf/acl.auth.php.dist conf/acl.auth.php
EOH
end

# Local users provider. It contains usernames and passwords,
# full names, emails and groups
template '/var/www/html/conf/users.auth.php.template' do
  source 'users.auth.php.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
end

# Presence of this file prevents installation page from showing by default.
template '/var/www/html/conf/local.php' do
  source 'local.php.erb'
  owner 'www-data'
  group 'www-data'
  mode '0644'
end

# Add additional configuration for www site
template '/etc/apache2/sites-available/dokuwiki.conf' do
  source 'dokuwiki.conf.erb'
end

execute 'a2ensite dokuwiki'

# Post deployment configuration - custom admin password
c2d_startup_script 'dokuwiki' do
  source 'dokuwiki'
  action :cookbook_file
end
