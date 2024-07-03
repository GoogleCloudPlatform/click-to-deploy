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

include_recipe 'git'

include_recipe 'php74'
include_recipe 'php74::module_libapache2'
include_recipe 'php74::module_mbstring'
include_recipe 'php74::module_pgsql'

apt_update do
  action :update
end

# Clone phpPgAdmin source code per license requirements.
# Repository branch name follows the pattern: REL_7-13-0.
git '/usr/src/phppgadmin' do
  repository 'https://github.com/phppgadmin/phppgadmin.git'
  reference "REL_#{node['phppgadmin']['version']}"
  action :checkout
end

bash 'Configure application' do
  user 'root'
  code <<-EOH
  # Copy application to setup folder
  cp -rf /usr/src/phppgadmin/ /usr/share/

  # Remove PHP closing tag from template
  # and generate actual config file.
  cd /usr/share/phppgadmin/conf
  cat config.inc.php-dist | sed 's/?>//g' > config.inc.php

  # Add localhost to configuration file
  echo "\\$conf['servers'][0]['host'] = 'localhost'; ?>" >> config.inc.php
EOH
end

# phpPgAdmin Apache configuration template
cookbook_file '/etc/apache2/conf-available/phppgadmin.conf' do
  source 'phppgadmin-apache.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

execute 'enable-phppgadmin-config' do
  command 'a2enconf phppgadmin'
end

service 'apache2' do
  action [ :enable, :restart ]
end

c2d_startup_script 'phppgadmin-setup'
