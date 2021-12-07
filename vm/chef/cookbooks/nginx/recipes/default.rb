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

# install nginx package
apt_repository 'nginx' do
  uri node['nginx']['repo']['uri']
  components node['nginx']['repo']['components']
  distribution node['nginx']['repo']['distribution']
  key node['nginx']['repo']['keyserver']
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

package 'install packages' do
  package_name node['nginx']['packages']
  action :install
end

directory '/etc/nginx/sites-available' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

directory '/etc/nginx/sites-enabled' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

template '/etc/nginx/nginx.conf' do
  source 'nginx.conf.erb'
end

service 'nginx' do
  action :reload
end

file '/etc/nginx/conf.d/default.conf' do
  action :delete
end
