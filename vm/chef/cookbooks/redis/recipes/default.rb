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
# The official Redis website states that downloading the sources
# and compiling them is the recommended way of Redis installation.
# https://redis.io/topics/quickstart

# Download Redis
remote_file '/usr/src/redis.tar.gz' do
  source node['redis']['download_url']
  action :create
end

apt_update do
  action :update
end

# Install dependencies
package 'install_dependencies' do
  package_name node['redis']['packages']['all_dependencies']
  action :install
end

# Extract the tarball
bash 'extract_redis_sources' do
  cwd '/usr/src'
  code <<-EOH
    tar xvzf redis.tar.gz
    mv "redis-#{node['redis']['version']}" redis
EOH
end

# Build Redis from extracted sources
bash 'build_redis' do
  cwd '/usr/src/redis'
  code <<-EOH
    make
    make install
EOH
end

# Create directories for Redis environment
directory '/etc/redis'
directory '/var/lib/redis'
directory '/var/log/redis'

# Copy main redis configuration file
cookbook_file '/etc/redis/redis.conf' do
  source 'redis.conf'
end

# Copy redis unit file
cookbook_file '/etc/systemd/system/redis-server.service' do
  source 'redis-server.service'
end

# Copy redis-sentinel unit file
cookbook_file '/etc/systemd/system/redis-sentinel.service' do
  source 'redis-sentinel.service'
end

# Create empty file for additional configuration that will come after startup
file '/etc/redis/redis_node.conf'

# Copy sentinel configuration template.
# It will be filled up by the startup script.
cookbook_file '/etc/redis/sentinel.conf.template' do
  source 'sentinel.conf.template'
end

# Remove temp dependencies
package 'remove_temporary_deps' do
  package_name node['redis']['packages']['temp_dependencies']
  action :purge
end

c2d_startup_script 'redis'
