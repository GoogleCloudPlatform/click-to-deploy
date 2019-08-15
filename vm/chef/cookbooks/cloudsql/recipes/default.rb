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
#
# Cloud SQL Setup

# Download the proxy binary
# https://cloud.google.com/sql/docs/mysql/connect-compute-engine#gce-connect-proxy
remote_file '/opt/c2d/downloads/cloud_sql_proxy' do
  source node['cloudsql']['binary']
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Drop script that executes the binary
cookbook_file '/opt/c2d/downloads/cloudsql-proxy' do
  source 'cloudsql-proxy.sh'
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Drop service file that runs the cloudsql-proxy script
cookbook_file '/lib/systemd/system/cloudsql-proxy.service' do
  source 'cloudsql-proxy.service'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

user 'cloudsqluser' do
  action :create
  comment 'Used to start cloudsql-proxy serivce'
end

service 'cloudsql-proxy' do
  action :enable
end
