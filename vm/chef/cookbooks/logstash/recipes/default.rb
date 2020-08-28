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

include_recipe 'openjdk11'

apt_update 'update' do
  action :update
end

# Install the package required to apt-get update with elasticsearch repo
package 'apt-transport-https' do
  action :install
end

# Configure elasticsearch repository
apt_repository 'add_elastic_co_repo' do
  uri node['logstash']['repository_url']
  components ['stable', 'main']
  keyserver node['logstash']['keyserver_url']
  distribution false
  trusted true
end

apt_update 'update' do
  action :update
end

# Install Logstash
package 'logstash' do
  action :install
end

bash 'Assign logstash to group adm' do
  user 'root'
  code <<-EOH
  usermod -aG adm logstash
EOH
end

# Copy the utils file for logstash startup
cookbook_file '/opt/c2d/logstash-utils' do
  source 'logstash-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# Copy configuration templates
cookbook_file '/etc/logstash/conf.d/syslog.conf.template' do
  source 'syslog.conf.template'
  owner 'root'
  group 'root'
  mode '0640'
end

# Copy startup script
c2d_startup_script 'logstash'
