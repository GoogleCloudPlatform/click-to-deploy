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
