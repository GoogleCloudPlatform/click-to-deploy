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

include_recipe 'mysql::version-8.0-embedded'
include_recipe 'git'
include_recipe 'mattermost::ospo'

# https://docs.mattermost.com/install/software-hardware-requirements.html#database-software
mysql_enable_native_password 'Enable mysql_native_password config'

apt_update do
  action :update
end

package 'Install Packages' do
  package_name node['mattermost']['packages']
  action :install
end

bash 'Configure MySQL database' do
  user 'root'
  code <<-EOH
# create db
mysql -u root -e "CREATE DATABASE $defdb CHARACTER SET utf8 COLLATE utf8_general_ci";
EOH
  environment({
    'defdb' => node['mattermost']['db']['name'],
  })
end

user node['mattermost']['user'] do
  action :create
  home "/home/#{node['mattermost']['user']}"
  password node['mattermost']['password']
  shell '/bin/bash'
  manage_home true
end

directory '/opt/mattermost/data' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

['setup', 'utils'].each do |file|
  cookbook_file "/opt/mattermost-#{file}" do
    source "mattermost-#{file}"
    owner 'root'
    group 'root'
    mode 0755
    action :create
  end
end

remote_file '/tmp/mattermost-server.tar.gz' do
  source "https://releases.mattermost.com/#{node['mattermost']['version']}/mattermost-#{node['mattermost']['version']}-linux-amd64.tar.gz"
  checksum node['mattermost']['sha256']
  action :create
end

bash 'Extract Mattermost' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    tar --extract \
        --file mattermost-server.tar.gz \
        --directory /opt/mattermost \
        --strip-components 1 \
    && rm -f mattermost-server.tar.gz
EOH
end

bash 'Assign permissions' do
  user 'root'
  code <<-EOH
  chown -R mattermost:mattermost /opt/mattermost
  chmod -R g+w /opt/mattermost
EOH
end

cookbook_file '/lib/systemd/system/mattermost.service' do
  source 'mattermost.service'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

service 'mattermost.service' do
  action [ :stop ]
end

['domain', 'localhost'].each do |file|
  cookbook_file "/opt/mattermost-nginx-#{file}.conf" do
    source "mattermost-nginx-#{file}.conf"
    owner 'root'
    group 'root'
    mode 0664
    action :create
  end
end

# Downloads certbot to enable user to easily generate
# certificate using Let's Encrypt
git '/opt/certbot' do
  repository 'https://github.com/certbot/certbot.git'
  checkout_branch "v#{node['mattermost']['certbot']['version']}"
  action :checkout
end

c2d_startup_script 'mattermost-setup'
