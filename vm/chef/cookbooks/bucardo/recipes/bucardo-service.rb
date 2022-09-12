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

include_recipe 'bucardo::default'

remote_file '/tmp/bucardo.tar.gz' do
  source "http://bucardo.org/downloads/Bucardo-#{node['bucardo']['version']}.tar.gz"
  action :create
end

bash 'Extract Bucardo' do
  cwd '/tmp'
  code <<-EOH
    mkdir -p bucardo/ \
      && tar xvfz bucardo.tar.gz  -C bucardo/ --strip-components=1
EOH
end

bash 'Install Bucardo Service' do
  cwd '/tmp/bucardo'
  code <<-EOH
    perl Makefile.PL \
      && make install \
      && mkdir -p /var/run/bucardo \
      && mkdir -p /var/log/bucardo \
      && chmod 777 /var/run/bucardo
EOH
end

# Prepare directory for licenses
directory '/usr/src/licenses' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Download License
remote_file 'Bucardo License' do
  path '/usr/src/licenses/bucardo_license'
  source 'https://raw.githubusercontent.com/bucardo/bucardo/master/LICENSE'
end
