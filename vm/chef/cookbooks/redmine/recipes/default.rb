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

ENV['DEBIAN_FRONTEND'] = 'noninteractive'

include_recipe 'apache2'
include_recipe 'apache2::mod-passenger'
include_recipe 'apache2::security-config'
include_recipe 'mysql'

# Configure redmine package (preventing interactive dialogs to show up):
bash 'configure_apache_site' do
  user 'root'
  code <<-EOH
debconf-set-selections <<< "redmine redmine/instances/default/database-type select mysql"
debconf-set-selections <<< "redmine redmine/instances/default/dbconfig-install boolean true"
debconf-set-selections <<< "redmine redmine/instances/default/db/app-user string redmineuser"
debconf-set-selections <<< "redmine redmine/instances/default/mysql/app-user string redmineuser"
debconf-set-selections <<< "redmine redmine/instances/default/mysql/app-pass password"
debconf-set-selections <<< "redmine redmine/instances/default/mysql/admin-user string root"
debconf-set-selections <<< "redmine redmine/instances/default/mysql/admin-pass password"
EOH
end

# Install redmine-related packages:
package 'install_redmine_packages' do
  package_name node['redmine']['packages']
  action :install
  retries 10
  retry_delay 60
end

# Configure Redmine site in Apache and enable it with Apache's passenger module
bash 'configure_apache_site' do
  user 'root'
  code <<-EOH
cp /usr/share/doc/redmine/examples/apache2-passenger-host.conf /etc/apache2/sites-available/redmine.conf
a2dissite 000-default.conf
a2ensite redmine.conf
EOH
end

service 'reload_apache2' do
  service_name 'apache2'
  action [ :reload ]
end

# Copy Redmine's database connection configuration template:
template '/usr/share/redmine/database.yml.template' do
  source 'database.yml.erb'
  owner 'root'
  group 'www-data'
  mode '0640'
end

# Copy post-deploy configuration script (to override and configure instance's specific passwords):
c2d_startup_script 'redmine' do
  source 'redmine-startup'
  action :cookbook_file
end

# Remove all AGPL licensed packages installed automatically by Redmine.
package node['redmine']['agpl_packages'] do
  action :remove
  retries 10
  retry_delay 60
end
