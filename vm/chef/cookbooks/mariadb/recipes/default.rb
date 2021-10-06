# Copyright 2020 Google LLC
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

apt_repository 'mariadb_repository' do
  uri node['mariadb']['repo']['uri']
  components node['mariadb']['repo']['components']
  keyserver node['mariadb']['repo']['keyserver']
  distribution node['mariadb']['repo']['distribution']
  trusted true
  deb_src true
end

apt_update 'update' do
  action :update
end

apt_preference 'mariadb-server' do
  pin          "version #{node['mariadb']['apt_version']}"
  pin_priority '1000'
end

package 'mariadb-server' do
  :install
end

['pam-ssh', 'ssh', 'master-replication', 'replica-replication'].each do |file|
  cookbook_file "/opt/c2d/patch-#{file}" do
    source "patch-#{file}"
    owner 'root'
    group 'root'
    mode 0664
    action :create
  end
end

['setup', 'utils'].each do |file|
  cookbook_file "/opt/c2d/mariadb-#{file}" do
    source "mariadb-#{file}"
    owner 'root'
    group 'root'
    mode 0755
    action :create
  end
end

service 'mysql' do
  action [ :enable ]
end

c2d_startup_script 'mariadb-setup'
