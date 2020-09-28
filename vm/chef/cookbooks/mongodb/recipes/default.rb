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

# Enable the mongod service to make it autostart on boot.
execute 'systemctl enable mongod.service'

cookbook_file '/etc/mongod.arb.conf.template' do
  source 'conf/mongod.arb.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/etc/mongod.serv.conf.template' do
  source 'conf/mongod.serv.conf'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

c2d_startup_script 'mongodb-server' do
  source 'startup/mongodb-server'
end

c2d_startup_script 'mongodb-arbiter' do
  source 'startup/mongodb-arbiter'
end

c2d_startup_script 'mongodb-validator' do
  source 'startup/mongodb-validator'
end

# Prepare directory for sources and licenses
directory '/usr/src/licenses' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Download MongoDB source.
# MongoDB source is published under the name mongodb.
execute 'download_mongodb_source_code' do
  command "apt-get source -y #{node['mongodb']['source_package']}"
  cwd '/usr/src'
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
