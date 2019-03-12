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

include_recipe 'c2d-config::packages-wishes'

directory '/opt/c2d' do
  owner 'root'
  group 'root'
  mode  0755
  action :create
end

directory '/opt/c2d/scripts' do
  owner 'root'
  group 'root'
  mode  0755
  action :create
end

directory node['c2d-config']['config-dir'] do
  owner 'root'
  group 'root'
  mode  0755
  action :create
end

cookbook_file '/opt/c2d/c2d-startup' do
  source 'c2d-startup'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/runtime-config-post-result' do
  source 'runtime-config-post-result'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/c2d-utils' do
  source 'c2d-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

c2d_startup_script 'manage-swap'

cookbook_file '/lib/systemd/system/google-c2d-startup.service' do
  source 'google-c2d-startup.service'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

service 'google-c2d-startup.service' do
  action :enable
end

directory '/opt/c2d/downloads' do
  owner 'root'
  group 'root'
  mode  0755
  action :create
end
