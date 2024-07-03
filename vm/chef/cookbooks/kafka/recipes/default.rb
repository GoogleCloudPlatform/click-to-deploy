# Copyright 2024 Google LLC
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
# Reference: https://kafka.apache.org/quickstart

include_recipe 'kafka::ospo'

# Install ZooKeeper which also pulls down java as a dependency
package 'install packages' do
  package_name node['kafka']['packages']
  action :install
end

# Make the dir where kafka will live
directory '/opt/kafka' do
  owner 'root'
  group 'root'
  mode '0755'
  action :create
end

# Download md5 checksum from apache
remote_file '/tmp/kafka-checksum.md5' do
  source "https://archive.apache.org/dist/kafka/#{node['kafka']['version']}/kafka_#{node['scala']['version']}-#{node['kafka']['version']}.tgz.md5"
  action :create
end

# Download Kafka
remote_file '/tmp/kafka.tgz' do
  source "https://archive.apache.org/dist/kafka/#{node['kafka']['version']}/kafka_#{node['scala']['version']}-#{node['kafka']['version']}.tgz"
  verify 'sed -i -e "s/.*: \(.*\)/\1/; s/ //g; s=$=  %{path}=" /tmp/kafka-checksum.md5 && md5sum -c /tmp/kafka-checksum.md5'
  action :create
end

bash 'Configure Kafka Scripts' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # Extract the tarball in /tmp and move the contents to /opt/kafka
    tar -xf kafka.tgz
    mv ./kafka_#{node['scala']['version']}-#{node['kafka']['version']}/* /opt/kafka

    # Update /etc/profile so kafka scripts are avaiable in the PATH
    sed -i 's;^  PATH=.*;  PATH='\""$PATH":/opt/kafka/bin\"';' /etc/profile
EOH
end

# Create a systemd service file to start kafaka on boot every time
cookbook_file '/lib/systemd/system/kafka.service' do
  source 'kafka-startup.service'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

cookbook_file '/opt/kafka/bin/c2d-service.sh' do
  source 'c2d-service.sh'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

service 'kafka.service' do
  action :enable
end

cookbook_file '/opt/c2d/kafka-utils' do
  source 'kafka-utils'
  owner 'root'
  group 'root'
  mode 0644
  action :create
end

# Copy startup script
c2d_startup_script 'kafka'
