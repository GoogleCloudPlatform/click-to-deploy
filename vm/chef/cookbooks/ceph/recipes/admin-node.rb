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
include_recipe 'ceph::common'

package 'install admin packages' do
  package_name node['ceph']['adminnodepackages']
  action :install
end

directory node['ceph']['config-dir'] do
  owner node['ceph']['deploymentuser']
  group node['ceph']['deploymentuser']
  mode '0755'
  action :create
end

directory node['ceph']['rsync-dir'] do
  owner node['ceph']['deploymentuser']
  group node['ceph']['deploymentuser']
  mode '0755'
  action :create
end

template '/etc/rsyncd.conf' do
  source 'etc-rsyncd.conf.erb'
  owner  'root'
  group  'root'
  mode   '0750'
end

service 'rsync' do
  action [ :enable, :restart ]
end

c2d_startup_script 'ceph-admin-node' do
  source 'opt-c2d-scripts-ceph-admin-node.erb'
  action :template
end
