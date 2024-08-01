# Copyright 2023 Google LLC
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

file "/home/#{node['ceph']['deploymentuser']}/.ssh/authorized_keys" do
  owner node['ceph']['deploymentuser']
  group node['ceph']['deploymentuser']
  mode '0755'
  action :create
end

package 'packages' do
  package_name node['ceph']['datanodepackages']
  options '--no-install-recommends'
  action :install
end

c2d_startup_script 'ceph-data-node' do
  source 'opt-c2d-scripts-ceph-data-node.erb'
  action :template
end
