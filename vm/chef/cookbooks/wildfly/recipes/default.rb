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

include_recipe 'openjdk11'

apt_update 'update' do
  action :update
end

user node['wildfly']['user'] do
  action :create
  home "/home/#{node['wildfly']['user']}"
  password node['wildfly']['password']
  shell '/bin/bash'
  manage_home true
end

remote_file '/tmp/wildfly.tar.gz' do
  source "https://download.jboss.org/wildfly/#{node['wildfly']['version']}.Final/wildfly-#{node['wildfly']['version']}.Final.tar.gz"
  checksum node['wildfly']['sha256']
  action :create
end

bash 'Install Wildfly' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    mkdir -p /tmp/wildfly \
    && tar xf /tmp/wildfly.tar.gz -C /tmp/wildfly --strip-components=1 \
    && mkdir -p "${jboss_home}" \
    && mv -f /tmp/wildfly "${jboss_home}/../" \
    && rm -f wildfly.tar.gz \
    && chown -R jboss:jboss "${jboss_home}" \
    && chmod -R g+rw "${jboss_home}"
EOH
  environment({
    'jboss_home' => node['wildfly']['jboss_home'],
  })
end

cookbook_file '/lib/systemd/system/wildfly.service' do
  source 'wildfly.service'
  owner 'root'
  group 'root'
  mode 0664
  action :create
end

service 'wildfly.service' do
  action [ :enable, :start ]
end

c2d_startup_script 'wildfly'
