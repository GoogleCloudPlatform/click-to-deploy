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
#
# Reference: https://www.resourcespace.com/knowledge-base/systemadmin/general_requirements
#            https://www.resourcespace.com/knowledge-base/systemadmin/install_ubuntu
include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'mysql::version-8.0-embedded'

include_recipe 'php81'
include_recipe 'php81::module_curl'
include_recipe 'php81::module_dev'
include_recipe 'php81::module_gd'
include_recipe 'php81::module_intl'
include_recipe 'php81::module_ldap'
include_recipe 'php81::module_libapache2'
include_recipe 'php81::module_mbstring'
include_recipe 'php81::module_mysql'
include_recipe 'php81::module_xml'
include_recipe 'php81::module_zip'
include_recipe 'git'

apt_update do
  action :update
end

package 'Install Packages' do
  package_name node['resourcespace']['packages']
  action :install
end

bash 'Checkout Resourcespace' do
  user 'root'
  code <<-EOH
    svn co http://svn.resourcespace.com/svn/rs/releases/${version} /var/www/html
  EOH
  environment({
    'version' => node['resourcespace']['version'],
  })
end

# Reference: https://www.resourcespace.com/knowledge-base/systemadmin/install_php_ini
bash 'Configure PHP' do
  user 'root'
  code <<-EOH
    sed -i 's/memory_limit = .*/memory_limit = 999M/' /etc/php/*/apache2/php.ini
    sed -i 's/upload_max_filesize = .*/upload_max_filesize = 999M/' /etc/php/*/apache2/php.ini
    sed -i 's/post_max_size = .*/post_max_size = 999M/' /etc/php/*/apache2/php.ini
    sed -i 's/max_execution_time = .*/max_execution_time = 120/' /etc/php/*/apache2/php.ini
EOH
end

bash 'Configure Database' do
  user 'root'
  code <<-EOH
    mysql -u root -e "CREATE DATABASE $default_db CHARACTER SET utf8 COLLATE utf8_unicode_ci";
  EOH
  environment({
    'default_db' => node['resourcespace']['db']['name'],
  })
end

['include', 'filestore'].each do |folder|
  directory "/var/www/html/#{folder}" do
    owner 'root'
    group 'root'
    mode 0777
    recursive true
    action :create
  end
end

# Copy the utils file for resourcespace startup
cookbook_file '/opt/c2d/resourcespace-utils' do
  source 'resourcespace-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# Set up the cron job for relevance matching and periodic emails
cookbook_file '/etc/cron.daily/resourcespace' do
  source 'resourcespace.cron'
  owner 'root'
  group 'root'
  mode 0755
end

# Copy the utils file for resourcespace startup
cookbook_file '/opt/c2d/resourcespace-utils' do
  source 'resourcespace-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

# OSPO Requirements
# Copy source-code due required components
git '/var/www/html/lib/crystal-project' do
  repository 'https://github.com/thecodingmachine/crystal-project.git'
  action :checkout
end

git '/var/www/html/lib/TCPDF' do
  repository 'https://github.com/tecnickcom/TCPDF.git'
  action :checkout
end

# Copy licenses due required components
bash 'Download pending licenses' do
  cwd '/var/www/html/documentation/licenses'
  user 'root'
  code <<-EOH
  wget -O annotorious.txt https://raw.githubusercontent.com/recogito/annotorious/main/LICENSE \
    && wget -O OpenLayers.txt https://raw.githubusercontent.com/openlayers/openlayers/main/LICENSE.md \
    && wget -O tcpdf.txt https://raw.githubusercontent.com/tecnickcom/TCPDF/main/LICENSE.TXT
EOH
end

c2d_startup_script 'resourcespace'
