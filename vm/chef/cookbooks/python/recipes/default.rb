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

# Update sources
apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

# Install Deps Packages
package 'Install Deps Packages' do
  action :install
  package_name node['python']['deps_packages']
end

directory '/usr/src/' do
  owner 'root'
  group 'root'
  mode '0644'
  recursive true
  action :create
end

remote_file '/usr/src/python.tgz' do
  source "https://www.python.org/ftp/python/#{node['python']['version']}/Python-#{node['python']['version']}.tgz"
  action :create
end

bash 'install' do
  user 'root'
  cwd '/usr/src'
  code <<-EOH
  tar -zxvf /usr/src/python.tgz
  (cd Python-#{node['python']['version']} && ./configure --enable-optimizations)
  (cd Python-#{node['python']['version']} && make && make altinstall)
EOH
end
