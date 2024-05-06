# Copyright 2024 Google LLC
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
include_recipe 'apache2::security-config'
include_recipe 'apache2::mod-rewrite'
include_recipe 'mysql::version-8.0-embedded'
include_recipe 'php83'
include_recipe 'php83::module_libapache2'
include_recipe 'php83::module_mysql'
include_recipe 'phpmyadmin'

include_recipe 'lamp::ospo'

cookbook_file '/etc/apache2/sites-available/lamp-server.conf' do
  source 'lamp-server.conf'
end

execute 'enable cgi module' do
  command 'a2enmod cgi'
end

execute 'disable default site' do
  command 'a2dissite 000-default'
end

execute 'enable lamp server' do
  command 'a2ensite lamp-server'
end

service 'apache2' do
  action [ :enable, :restart ]
end
