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

# Reference: https://docs.moodle.org/34/en/Installing_Moodle_on_Debian_based_distributions
include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

include_recipe 'mysql'
include_recipe 'php7'
include_recipe 'php7::module_curl'
include_recipe 'php7::module_gd'
include_recipe 'php7::module_intl'
include_recipe 'php7::module_libapache2'
include_recipe 'php7::module_mysql'
include_recipe 'php7::module_xml'
include_recipe 'php7::module_xmlrpc'
include_recipe 'php7::module_zip'

remote_file '/tmp/moodle.tgz' do
  source "https://download.moodle.org/download.php/direct/stable#{node['moodle']['version']}/moodle-latest-#{node['moodle']['version']}.tgz"
  action :create
end

bash 'configure moodle' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # Extract to /var/www/html and skip moodle directory
    tar -xf moodle.tgz -C /var/www/html --strip-components 1

    chown -R $user:$user /var/www/html/

    mysql -u root -e "CREATE DATABASE $defdb"
EOH
  environment({
    'user' => node['moodle']['user'],
    'defdb' => node['moodle']['db']['name'],
  })
end

directory '/var/www/moodledata' do
  owner node['moodle']['user']
  group node['moodle']['group']
  action :create
  mode '0755'
end

cron 'configure cron' do
  user node['moodle']['user']
  minute '*/10'
  command 'php /var/www/html/admin/cli/cron.php > /dev/null'
  action :create
end

c2d_startup_script 'moodle'

cookbook_file '/etc/apache2/sites-available/moodle.conf' do
  source 'moodle.conf'
end

execute 'enable moodle.conf' do
  command 'a2ensite moodle'
end
