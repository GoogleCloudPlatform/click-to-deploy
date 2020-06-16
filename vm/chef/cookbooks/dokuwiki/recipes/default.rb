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
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'php73'
include_recipe 'php73::module_libapache2'
include_recipe 'php73::module_xml'

# Restart Apache2 to have php modules enabled and active.
service 'apache2' do
  action :restart
end

# Download, untar and mark as owned by www-data all files of DokuWiki.
remote_file '/tmp/dokuwiki.tgz' do
  source 'https://download.dokuwiki.org/src/dokuwiki/dokuwiki-stable.tgz'
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
