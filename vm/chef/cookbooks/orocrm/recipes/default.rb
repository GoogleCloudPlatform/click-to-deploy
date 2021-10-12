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
# Reference: https://doc.oroinc.com/backend/setup/dev-environment/community-edition/
include_recipe 'apache2'
include_recipe 'apache2::mod_deflate'
include_recipe 'apache2::mod_headers'

include_recipe 'mysql::version-8.0'

include_recipe 'git'

# Reference: https://doc.oroinc.com/backend/setup/system-requirements/
include_recipe 'php74'
include_recipe 'php74::module_curl'
include_recipe 'php74::module_ctype'
include_recipe 'php74::module_fileinfo'
include_recipe 'php74::module_gd'
include_recipe 'php74::module_intl'
include_recipe 'php74::module_json'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_mysql'
include_recipe 'php74::module_cli'
include_recipe 'php74::module_simplexml'
include_recipe 'php74::module_tokenizer'
include_recipe 'php74::module_xml'
include_recipe 'php74::module_zip'
include_recipe 'php74::module_imap'
include_recipe 'php74::module_soap'
include_recipe 'php74::module_bcmath'
include_recipe 'php74::module_ldap'
include_recipe 'php74::module_mongodb'
include_recipe 'php74::module_libapache2'

include_recipe 'composer::composer2'

include_recipe 'nodejs::default_nodejs14'

apt_update do
  action :update
end

# Clone Orocrm source code per license requirements.
git '/usr/src/orocrm' do
  repository 'https://github.com/oroinc/crm-application.git'
  reference node['orocrm']['version']
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
    'defdb' => node['orocrm']['db']['name'],
  })
end

# Copy Ora Apache configuration files
cookbook_file '/opt/c2d/apache-orocrm.conf' do
  source 'apache-orocrm.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'enable apache modules' do
  command 'a2enmod rewrite'
end

#c2d_startup_script 'orocrm'