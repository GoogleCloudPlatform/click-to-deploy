# Copyright 2022 Google LLC
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
# Reference: https://tomcat.apache.org/tomcat-10.0-doc/index.html
# Reference: https://www.mkyong.com/tomcat/tomcat-default-administrator-password/

include_recipe 'c2d-config'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'openjdk11'

# Create tomcat user.
user node['tomcat']['user'] do
  home '/home/tomcat'
  shell '/bin/bash'
  action :create
  manage_home true
end

# Create tomcat home directory.
directory '/opt/tomcat' do
  owner 'tomcat'
  group 'tomcat'
  mode '0755'
  action :create
end

# Assign permissions for home directory.
directory node['tomcat']['app']['install_dir'] do
  owner node['tomcat']['user']
  group node['tomcat']['user']
  mode '0755'
  action :create
  recursive true
end

# Download tomcat.
remote_file '/tmp/tomcat.tar.gz' do
  source "https://archive.apache.org/dist/tomcat/tomcat-10/v#{node['tomcat']['version']}/bin/apache-tomcat-#{node['tomcat']['version']}.tar.gz"
  verify "echo '#{node['tomcat']['sha256']} %{path}' | sha256sum -c"
  action :create
end

# Extract tomcat to home directory.
bash 'Extract Tomcat' do
  user 'tomcat'
  cwd '/tmp'
  code <<-EOH
tar -xf tomcat.tar.gz -C /opt/tomcat --strip-components=1
EOH
end

# Create tomcat service.
systemd_unit 'tomcat.service' do
  content <<~EOU
  [Unit]
  Description=Apache Tomcat Web Application Container
  After=network.target

  [Service]
  Type=forking

  Environment=JAVA_HOME=/usr/lib/jvm/java-1.11.0-openjdk-amd64
  Environment=CATALINA_PID=/opt/tomcat/temp/tomcat.pid
  Environment=CATALINA_HOME=/opt/tomcat
  Environment=CATALINA_BASE=/opt/tomcat
  Environment='CATALINA_OPTS=-Xms512M -Xmx1024M -server -XX:+UseParallelGC'
  Environment='JAVA_OPTS=-Djava.awt.headless=true -Djava.security.egd=file:/dev/./urandom'

  ExecStart=/opt/tomcat/bin/startup.sh
  ExecStop=/opt/tomcat/bin/shutdown.sh

  User=tomcat
  Group=tomcat
  UMask=0007
  RestartSec=10
  Restart=always

  [Install]
  WantedBy=multi-user.target
  EOU

  action [:create, :enable]
end

service 'tomcat' do
  action :reload
end

execute 'enable proxy_http' do
  command 'a2enmod proxy_http'
end

template '/etc/apache2/sites-available/tomcat.conf' do
  source 'tomcat.conf.erb'
end

execute 'enable tomcat.conf' do
  command 'a2ensite tomcat.conf'
end

bash 'add tomcat groups' do
  user 'root'
  code <<-EOH
sed -i -e '$ i \\
\\
  <role rolename="manager-gui"/>\\
  <role rolename="admin-gui"/>\\
' /opt/tomcat/conf/tomcat-users.xml
EOH
end

c2d_startup_script 'tomcat' do
  source 'tomcat'
  action :cookbook_file
end
