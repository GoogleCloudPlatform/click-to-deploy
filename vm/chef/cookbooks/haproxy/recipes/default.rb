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

include_recipe 'haproxy::ospo'
# install haproxy package
apt_repository 'haproxy' do
  uri node['haproxy']['repo']['uri']
  components node['haproxy']['repo']['components']
  distribution node['haproxy']['repo']['distribution']
  key node['haproxy']['repo']['keyserver']
  trusted true
  deb_src true
end

apt_update 'update' do
  action :update
end

apt_preference 'haproxy' do
  pin          "version #{node['haproxy']['apt_version']}"
  pin_priority '1000'
end

package 'haproxy' do
  :install
end

template '/etc/haproxy/haproxy.cfg' do
  source 'haproxy.cfg.erb'
  owner 'root'
  group 'root'
  mode 0644
  notifies :start, 'service[haproxy]'
end

service 'haproxy' do
  action :start
end
