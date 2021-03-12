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

include_recipe 'mongodb::common'
include_recipe 'mongodb::licenses'

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

include_recipe 'mongodb::uninstall_temp'
