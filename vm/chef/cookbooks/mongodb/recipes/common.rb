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

include_recipe 'git'

apt_update do
  action :update
end

package 'install_temp_package' do
  package_name node['mongodb']['temp_packages']
  action :install
end

package 'install_permanent_packages' do
  package_name node['mongodb']['permanent_packages']
  action :install
end

apt_repository 'add_mongo_repository' do
  uri 'http://repo.mongodb.org/apt/debian'
  components ['main']
  keyserver 'hkp://keyserver.ubuntu.com:80'
  distribution "#{node['mongodb']['debian']['codename']}/mongodb-org/#{node['mongodb']['release']}"
  trusted true
end

package 'install_mongodb' do
  package_name node['mongodb']['package']
  action :install
end

# Disable transparent hugepages according to:
# https://docs.mongodb.com/manual/tutorial/transparent-huge-pages/
cookbook_file '/etc/init.d/disable-transparent-hugepages' do
  source 'disable-transparent-hugepages'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

execute 'update-rc.d disable-transparent-hugepages defaults'
