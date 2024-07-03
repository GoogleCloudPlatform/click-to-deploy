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
#
# Reference: https://docs.weblate.org/en/latest/admin/install/venv-debian.html

node.override['postgresql']['standalone']['allow_external'] = false

include_recipe 'git'
include_recipe 'nginx'
include_recipe 'postgresql::standalone_bullseye'
include_recipe 'redis::standalone'

apt_update do
  action :update
end

user 'weblate' do
  action :create
end

package 'Install dependencies' do
  package_name node['weblate']['packages']
  action :install
end

# Clone Weblate source code per license requirements.
git '/usr/src/weblate' do
  repository 'https://github.com/WeblateOrg/weblate.git'
  reference "weblate-#{node['weblate']['version']}"
  action :checkout
end

bash 'Install Dependencies' do
  user 'root'
  code <<-EOH
    virtualenv --python=python3 /opt/weblate-env
    source /opt/weblate-env/bin/activate
    pip install #{node['weblate']['pip-packages']}
EOH
end

cookbook_file '/opt/c2d/weblate-settings.py' do
  source 'settings.py'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/weblate-env/weblate.uwsgi.ini' do
  source 'weblate.uwsgi.ini'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/etc/nginx/sites-available/weblate.conf' do
  source 'weblate.nginx'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/lib/systemd/system/weblate.service' do
  source 'weblate.service'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

service 'weblate.service' do
  action [ :disable, :stop ]
end

cookbook_file '/opt/c2d/weblate-utils' do
  source 'weblate-utils'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

c2d_startup_script 'weblate'
