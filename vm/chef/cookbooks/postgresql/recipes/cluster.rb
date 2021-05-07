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

include_recipe 'bucardo'

execute 'add repo' do
  command 'echo "deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main" | tee -a /etc/apt/sources.list.d/pgdg.list'
end

execute 'install repo key' do
  command 'curl -s https://www.postgresql.org/media/keys/ACCC4CF8.asc | apt-key add -'
end

apt_update do
  action :update
end

package 'install packages' do
  package_name node['postgresql']['cluster']['packages']
  action :install
end

cookbook_file '/opt/c2d/pgcluster-utils' do
  source 'pgcluster-utils'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

cookbook_file '/opt/c2d/dump.sql' do
  source 'dump.sql'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

# Prepare directory for licenses
directory '/usr/src/licenses' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

remote_file 'Postgres License' do
  path '/usr/src/licenses/postgres_license'
  source 'https://raw.githubusercontent.com/postgres/postgres/master/COPYRIGHT'
end

bash 'configure postgresql' do
  user 'root'
  code <<-EOH
  set -x
  set -e
  echo 'host    all     postgres        0.0.0.0/0          md5' >> /etc/postgresql/*/main/pg_hba.conf
  sed -i "s/^#listen_addresses = 'localhost'/listen_addresses = '*'/" /etc/postgresql/*/main/postgresql.conf
EOH
end

c2d_startup_script 'postgresql' do
  source 'postgresql'
  action :cookbook_file
end

service 'postgresql' do
  action [ :enable, :start ]
end

c2d_startup_script 'postgresql-cluster'
