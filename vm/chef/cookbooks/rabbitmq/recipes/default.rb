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
# Reference: https://www.rabbitmq.com/install-debian.html#apt

# Update sources
apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

# Install Deps Packages
package 'Install Deps Packages' do
  action :install
  package_name node['rabbitmq']['deps_packages']
end

repos = [
  { 'name' => 'rabbitmq', 'component' => 'main' },
  { 'name' => 'rabbitmq-erlang', 'component' => 'erlang-22.x' },
]

repos.each do |repo|
  apt_repository "configure_#{repo['name']}_repository" do
    uri "https://dl.bintray.com/#{repo['name']}/debian"
    components [repo['component']]
    keyserver 'https://github.com/rabbitmq/signing-keys/releases/download/2.0/rabbitmq-release-signing-key.asc'
    distribution 'buster'
    trusted true
  end
end

# Update sources
apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

package 'install_rabbitmq' do
  package_name 'rabbitmq-server'
  version node['rabbitmq']['package_version']
  action :install
end

# 1. Set the share cookie such that the erlang nodes can communicate
#    See https://www.rabbitmq.com/clustering.html#setup
# 2. Increase the maximum number of open file descriptors for rabbitmq-server
bash 'configure_rabbitmq' do
  code <<-EOH
    service rabbitmq-server stop
    echo 'developer-console-rabbitmq' > /var/lib/rabbitmq/.erlang.cookie
    echo 'ulimit -n 262144' >> /etc/default/rabbitmq-server
    service rabbitmq-server start
EOH
end

c2d_startup_script 'rabbitmq'

# Download the software license
directory '/usr/src/license' do
  action :create
end

remote_file '/usr/src/license/RabbitMQ_LICENSE_and_COPYRIGHT' do
  source node['rabbitmq']['license_url']
  mode '0640'
  action :create
end

# Download source code for RabbitMQ
package 'dpkg-dev' do
  action :install
end

bash 'download_rabbitmq_sources' do
  cwd '/usr/src'
  code <<-EOH
    apt-get source rabbitmq-server
EOH
end

package 'dpkg-dev' do
  action :remove
end
