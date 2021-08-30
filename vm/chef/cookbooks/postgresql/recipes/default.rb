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

include_recipe 'c2d-config'

apt_repository 'apt.postgresql.org' do
  uri node['postgresql']['repository_url']
  key node['postgresql']['key']
  components ['main']
  distribution "#{node['postgresql']['standalone']['distribution']}-pgdg"
end

apt_update do
  action :update
end

package 'install packages' do
  package_name node['postgresql']['packages']
  action :install
end

c2d_startup_script 'postgresql' do
  source 'postgresql'
  action :cookbook_file
end

service 'postgresql' do
  action [ :enable, :start ]
end
