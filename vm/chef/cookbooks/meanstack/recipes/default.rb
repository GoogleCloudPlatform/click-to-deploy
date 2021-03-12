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

include_recipe 'mongodb::standalone'
include_recipe 'nginx'
include_recipe 'nodenvm'
include_recipe 'nodenvm::node14'
include_recipe 'meanstack::api'
include_recipe 'meanstack::web'
include_recipe 'supervisord'

directory '/sites/homepage' do
  owner node['meanstack']['nginx']['user']
  group node['meanstack']['nginx']['group']
  mode '0755'
  recursive true
  action :create
end

remote_directory '/sites/homepage' do
  source 'homepage'
  owner node['meanstack']['nginx']['user']
  group node['meanstack']['nginx']['group']
  mode 0755
  action :create
end

bash 'Update Homepage' do
  user 'root'
  code <<-EOH
  sed -i 's/root \\/var\\/www\\/html\\;/root \\/sites\\/homepage\\;/g' /etc/nginx/sites-available/default
EOH
end

['mean', 'metrics'].each do |file|
  cookbook_file "/etc/nginx/sites-available/nginx-#{file}.conf" do
    source "conf/nginx-#{file}.conf"
    owner 'root'
    group 'root'
    mode 0755
    action :create
  end
end

# Configure supervisor
cookbook_file '/etc/supervisor/conf.d/supervisor-mean.conf' do
  source 'conf/supervisor-mean.conf'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

service 'supervisor' do
  action [ :enable, :stop ]
end

bash 'Copy licenses' do
  user 'root'
  code <<-EOH
  node_version="$(ls -l /usr/local/nvm/versions/node/ \
    | grep -v "total" \
    | awk '{ print $9 }')"
  node_dir="/usr/local/nvm/versions/node/${node_version}"
  target_dir="/usr/src/licenses"

  cp "${node_dir}/lib/node_modules/@angular/cli/node_modules/@schematics/angular/LICENSE" "${target_dir}/angular_LICENSE"
  cp "${node_dir}/lib/node_modules/express-generator/LICENSE" "${target_dir}/expressjs_LICENSE"
  cp "${node_dir}/LICENSE" "${target_dir}/nodejs_LICENSE"
EOH
end

# Copy the utils file for MEAN Stack startup
cookbook_file '/opt/c2d/meanstack-utils' do
  source 'meanstack-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# Copy startup script
c2d_startup_script 'meanstack'
