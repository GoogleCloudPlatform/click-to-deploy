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

include_recipe 'mongodb::uninstall_temp'
