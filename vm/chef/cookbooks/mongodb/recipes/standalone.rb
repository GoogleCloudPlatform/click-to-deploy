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

execute 'apt-get update'

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
  components ["#{node['mongodb']['debian']['codename']}/mongodb-org/#{node['mongodb']['release']}", 'main']
  keyserver 'hkp://keyserver.ubuntu.com:80'
  distribution false
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

directory '/data/db' do
  owner 'mongodb'
  group 'mongodb'
  mode '0755'
  recursive true
  action :create
end

# Enable the mongod service to make it autostart on boot.
service 'mongod.service' do
  action [ :enable, :start ]
end

cookbook_file '/etc/mongod.conf.template' do
  source 'conf/mongod.standalone.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

c2d_startup_script 'mongodb-standalone' do
  source 'startup/mongodb-standalone'
end

# Prepare directory for sources and licenses
directory '/usr/src/licenses' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Clone mongodb source code per license requirements.
git '/usr/src/mongodb' do
  repository 'https://github.com/mongodb/mongo.git'
  reference "v#{node['mongodb']['release']}"
  action :checkout
end

# Download the Software licenses
remote_file 'mongo_servers_and_tools_licenses' do
  path '/usr/src/licenses/MongoDb_Servers_and_Tools_LICENSE_and_COPYRIGHT'
  source 'http://www.gnu.org/licenses/agpl-3.0.txt'
end

remote_file 'mongo_drivers_licenses' do
  path '/usr/src/licenses/MongoDb_Drivers_LICENSE_and_COPYRIGHT'
  source 'http://www.apache.org/licenses/LICENSE-2.0.txt'
end

package 'uninstall_temp_package' do
  package_name node['mongodb']['temp_packages']
  action :purge
end
