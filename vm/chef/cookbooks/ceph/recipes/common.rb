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

include_recipe 'c2d-config::default'

apt_repository 'ceph' do
  uri          "https://download.ceph.com/debian-#{node['ceph']['version']}"
  components   ['main']
  key          'https://download.ceph.com/keys/release.asc'
end

user node['ceph']['deploymentuser'] do
  comment 'Ceph deployment user'
  home    "/home/#{node['ceph']['deploymentuser']}"
  shell   '/bin/bash'
end

template "/etc/sudoers.d/#{node['ceph']['deploymentuser']}" do
  source 'etc-sudoers.d-deploymentuser.erb'
  owner  'root'
  group  'root'
  mode   '0440'
  verify 'visudo -c -f %{path}'
  variables(cephdeploymentuser: node['ceph']['deploymentuser'])
end

directory "/home/#{node['ceph']['deploymentuser']}" do
  owner node['ceph']['deploymentuser']
  group node['ceph']['deploymentuser']
  mode '0750'
  action :create
end

directory "/home/#{node['ceph']['deploymentuser']}/.ssh" do
  owner node['ceph']['deploymentuser']
  group node['ceph']['deploymentuser']
  mode '0750'
  action :create
end

file "/home/#{node['ceph']['deploymentuser']}/.ssh/known_hosts" do
  owner node['ceph']['deploymentuser']
  group node['ceph']['deploymentuser']
  mode '0600'
  action :create
end

file "/home/#{node['ceph']['deploymentuser']}/.ssh/config" do
  owner node['ceph']['deploymentuser']
  group node['ceph']['deploymentuser']
  mode '0600'
  action :create
end
