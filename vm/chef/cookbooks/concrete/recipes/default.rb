# Copyright 2021 Google LLC
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
# Reference: https://documentation.concretecms.org/developers/introduction/installing-concrete-cms
include_recipe 'apache2'
include_recipe 'apache2::mod_deflate'
include_recipe 'apache2::mod_headers'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

include_recipe 'mysql::version-8.0-standalone'

include_recipe 'git'

# Reference: https://documentation.concretecms.org/developers/introduction/system-requirements
include_recipe 'php74'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_dom'
include_recipe 'php74::module_simplexml'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_curl'
include_recipe 'php74::module_mcrypt'
include_recipe 'php74::module_zip'
include_recipe 'php74::module_libapache2'

include_recipe 'composer::composer-only'

include_recipe 'nodejs::default_nodejs14'

apt_update do
  action :update
end

# Clone Concrete source code per license requirements.
git '/usr/src/concrete' do
  repository 'https://github.com/concrete5/concrete5.git'
  reference node['concrete']['version']
  action :checkout
end

bash 'Configure Database' do
  user 'root'
  cwd '/var/www/html'
  code <<-EOH
# create db
mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci";
EOH
  environment({
    'defdb' => node['concrete']['db']['name'],
  })
end

bash 'Set required mysqld options for Concrete' do
  code <<-EOH
    cat > /etc/my.cnf << 'EOF'
    #
    # Required mysqld options for Percona XtraDB Cluster
    [mysqld]
    default-authentication-plugin=mysql_native_password
    innodb_file_per_table = 0
    wait_timeout = 28800
EOF
EOH
end

# Copy Apache configuration files
cookbook_file '/opt/c2d/apache-concrete.conf' do
  source 'apache-concrete.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# Copy the utils file for Concrete startup
cookbook_file '/opt/c2d/concrete-utils' do
  source 'concrete-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

c2d_startup_script 'concrete'
