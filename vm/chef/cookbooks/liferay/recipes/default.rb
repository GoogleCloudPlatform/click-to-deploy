# Copyright 2023 Google LLC
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
include_recipe 'mysql::version-8.0-embedded'
include_recipe 'openjdk11'

apt_update do
  action :update
end

package 'Install Packages' do
  package_name node['liferay']['packages']
  action :install
end

group node['liferay']['linux']['user'] do
end

user node['liferay']['linux']['user'] do
  comment 'default liferay user'
  gid node['liferay']['linux']['user']
  home node['liferay']['home']
end

bash 'Setup ENV variables for liferay' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  cat << EOF >> /etc/environment
  LIFERAY_HOME='$liferay_home'
  JAVA_HOME='$java_home'
  PATH=$JAVA_HOME/bin:$PATH
  EOF
  EOH
  environment({
    'liferay_home' => node['liferay']['home'],
    'java_home' => node['liferay']['java']['home'],
  })
end

remote_file '/tmp/liferay-source.tar.gz' do
  source "https://github.com/liferay/liferay-portal/archive/refs/tags/#{node['liferay']['version']}.tar.gz"
  verify "echo '#{node['liferay']['sha1']['source']} %{path}' | sha1sum -c"
  action :create
end

bash 'Copy Liferay source code ' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    # Copy liferay source code for license compliance
    mkdir -p liferay-source
    tar xfvz liferay-source.tar.gz -C liferay-source
    mkdir -p /usr/src/liferay
    cp -r liferay-source/*/* /usr/src/liferay
  EOH
end

bash 'Install Liferay bundle' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  # Download Liferay Tomcat bundle for JAR dependencies
  curl -s https://api.github.com/repos/liferay/liferay-portal/releases/tags/$version | \
    jq --raw-output '.assets[].browser_download_url' | grep -E ".*tomcat.*\.(tar\.gz)$"| \
    xargs wget -q -O liferay-bundle.tar.gz
  echo "$sha1 liferay-bundle.tar.gz" | sha1sum -c || exit 1

  mkdir -p liferay-bundle
  tar -xf liferay-bundle.tar.gz -C liferay-bundle --strip-components 1
  mkdir -p $liferay_home
  cp -r liferay-bundle/* $liferay_home

  # Change permissions to liferay user
  chown -R $liferay_user:$liferay_user $liferay_home

  EOH
  environment({
    'version' => node['liferay']['version'],
    'sha1' => node['liferay']['sha1']['bundle'],
    'liferay_home' => node['liferay']['home'],
    'liferay_user' => node['liferay']['linux']['user'],
  })
end

# Copy startup script
cookbook_file '/etc/systemd/system/liferay.service' do
  source 'liferay-service'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

service 'liferay.service' do
  action [ :enable, :stop ]
end

bash 'MySQL configuration' do
  user 'root'
  code 'mysql -u root -e "CREATE DATABASE ${default_db} CHARACTER SET utf8 COLLATE utf8_general_ci"'
  environment({
    'default_db' => node['liferay']['db']['name'],
  })
end

bash 'Remove tmp files' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    rm -rf /tmp/liferay*
  EOH
end

c2d_startup_script 'liferay-db-setup'

c2d_startup_script 'liferay-setup'
