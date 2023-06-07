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
# Reference: https://www.drupal.org/documentation
# Reference: https://www.drupal.org/project/drupal

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql::version-8.0'

# Reference: https://www.drupal.org/docs/8/system-requirements/php
include_recipe 'php81'
include_recipe 'php81::module_curl'
include_recipe 'php81::module_gd'
include_recipe 'php81::module_libapache2'
include_recipe 'php81::module_mbstring'
include_recipe 'php81::module_mysql'
include_recipe 'php81::module_opcache'
include_recipe 'php81::module_xml'
include_recipe 'php81::module_zip'

remote_file '/tmp/drupal.tar.gz' do
  source 'https://www.drupal.org/download-latest/tar.gz'
  action :create
end

execute 'extract drupal' do
  cwd '/tmp'
  command 'tar -xf drupal.tar.gz -C /var/www/html --strip-components 1'
end

bash 'configuration' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
# missing files directory
mkdir sites/default/files
chmod a+w sites/default/files

# missing settings file
cp sites/default/default.settings.php sites/default/settings.php

chown -R $user .

# create db
mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8 COLLATE utf8_general_ci";
EOH
  environment({
    'user' => node['drupal']['user'],
    'defdb' => node['drupal']['db']['name'],
  })
end

template '/etc/apache2/sites-available/drupal.conf' do
  source 'drupal.conf.erb'
end

execute 'enable drupal.conf' do
  command 'a2ensite drupal'
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

file '/var/www/html/web.config.txt' do
  action :delete
end

execute 'move .gitignore ' do
  cwd '/var/www/html'
  command 'mv example.gitignore .gitignore'
end

c2d_startup_script 'drupal' do
  source 'drupal'
  action :cookbook_file
end
