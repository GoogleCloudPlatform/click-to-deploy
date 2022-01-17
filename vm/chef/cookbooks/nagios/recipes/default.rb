# Copyright 2022 Google LLC
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

include_recipe 'c2d-config::default'
include_recipe 'apache2::default'
include_recipe 'apache2::mod-rewrite'
include_recipe 'apache2::rm-index'

apt_update do
  action :update
end

# download nagios
remote_file "/tmp/#{node['nagios']['file']}" do
  source node['nagios']['url']
  action :create
end

template '/etc/apache2/sites-available/apache-nagios.conf' do
  source 'apache-nagios-conf.erb'
  cookbook 'nagios'
  owner 'root'
  group 'root'
  mode '0644'
end

# configure and install nagios
bash 'configure nagios' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # copy sources
    cp '#{node['nagios']['file']}' /usr/src/
    cd /usr/src/
    tar -xzf '#{node['nagios']['file']}'
EOH
end

service 'apache2' do
  action [ :enable ]
end

c2d_startup_script 'nagios'

execute 'enable apache modules' do
  command 'a2enmod cgi ssl'
end

execute 'disable apache default.conf' do
  command 'a2dissite 000-default'
end

execute 'enable nagios.conf' do
  command 'a2ensite default-ssl apache-nagios'
end
