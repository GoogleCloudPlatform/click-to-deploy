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
#
# Reference: https://kafka.apache.org/quickstart

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
