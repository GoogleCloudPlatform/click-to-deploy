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

node.override['postgresql']['standalone']['allow_external'] = false

include_recipe 'openjdk11'
include_recipe 'postgresql::standalone_buster'
include_recipe 'tomcat'

# Notes:
# 1) This recipe adds two new entries to /etc/hosts - pointing hostname to
#    local ips; see alse:
#    http://blog.itdhq.com/post/133135613685/alfresco-sdk-fixing-mysteriously-slow-tomcat
# 2) This recipe provides custom setenv.sh script for Alfresco Tomcat -
#    this is related to slow Alfresco startup; see also:
#    https://wiki.apache.org/tomcat/HowTo/FasterStartUp#Entropy_Source

# Prepare database configuration
bash 'configure_database' do
  user 'postgres'
  code <<-EOH
    psql -c "CREATE USER $user WITH PASSWORD '$pass';"
    psql -c "CREATE DATABASE $dbname OWNER $user ENCODING 'UTF8';"
EOH
  environment({
    'user' => node['alfresco']['db']['username'],
    'pass' => node['alfresco']['db']['password'],
    'dbname' => node['alfresco']['db']['name'],
  })
end

# Download installation file and verify its checksum
# NOTE: this operation is conducted without certificate check,
# because DigiCert's certificates are untrusted on Debian 9

apt_package 'zip' do
  action :install
end

# Download alfresco.
remote_file '/tmp/alfresco.zip' do
  source "#{node['alfresco']['install']['url']}"
  verify "echo '#{node['alfresco']['install']['sha256']} %{path}' | sha256sum -c"
  action :create
end

# Extract alfreso to home directory.
bash 'Extract Alfresco' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
unzip alfresco.zip -d /opt/alfresco
EOH
end

# Download SearchServices.
remote_file '/tmp/solr.zip' do
  source "#{node['alfresco']['search']['install']['url']}"
  verify "echo '#{node['alfresco']['search']['install']['sha256']} %{path}' | sha256sum -c"
  action :create
end

# Extract SearchServices to home directory.
bash 'Extract Solr' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
unzip solr.zip -d /opt/solr
EOH
end

user 'solr' do
  action :create
end

directory '/opt/solr' do
  owner 'solr'
  group 'solr'
  mode '0755'
  recursive true
  action :create
end

# Download Records Management.
remote_file '/tmp/rm.zip' do
  source "#{node['rm']['install']['url']}"
  verify "echo '#{node['rm']['install']['sha256']} %{path}' | sha256sum -c"
  action :create
end

directory '/opt/alfresco/rm-apts' do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Extract Records Management to home directory.
bash 'Extract Records Management' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
unzip rm.zip -d /opt/alfresco/rm-apts
EOH
end

# Download ActiveMQ.
remote_file '/tmp/activemq.zip' do
  source "#{node['activemq']['install']['url']}"
  verify "echo '#{node['activemq']['install']['sha256']} %{path}' | sha256sum -c"
  action :create
end

# Extract ActiveMQ to home directory.
bash 'Extract ActiveMQ' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
unzip activemq.zip -d /opt/activemq
EOH
end

user 'activemq' do
  action :create
end

directory '/opt/activemq' do
  owner 'activemq'
  group 'activemq'
  mode '0755'
  recursive true
  action :create
end

# Create an additional classpath to Tomcat

bash 'Move alfresco war file to tomcat' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    cp /opt/alfresco/web-server/webapps/*.* /opt/tomcat/webapps/
    cp /opt/alfresco/web-server/conf/Catalina/localhost/*.* /opt/tomcat/conf/Catalina/localhost/
    chown -R tomcat:tomcat /opt/tomcat/
EOH
end


# Configure Apache to server as Alfresco proxy:
#template '/etc/apache2/sites-available/alfresco.conf' do
#  source 'alfresco.conf.erb'
#  owner 'root'
#  group 'root'
#  mode '0640'
#end

#bash 'enable_alfresco_site_on_apache' do
#  code <<-EOH
#    a2enmod proxy proxy_http rewrite
#    a2dissite 000-default
#    a2ensite alfresco
#EOH
#end

#service 'apache2' do
#  action :restart
#end

# Copy alfresco-global.properties template configuration file (to override):
template '/opt/alfresco/alfresco-global.properties.template' do
  source 'alfresco-global.properties.template.erb'
  owner 'root'
  group 'root'
  mode '0640'
end

#directory '/opt/tomcat/shared/classes' do
#  owner 'root'
#  group 'root'
#  mode '0755'
#  recursive true
#  action :create
#end

#service 'tomcat' do
#  action :stop
#end

# Prepare Activemq to be run as service
template '/etc/systemd/system/activemq.service' do
  source 'activemq.service.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

# Prepare Solr to be run as service
template '/etc/systemd/system/solr.service' do
  source 'solr.service.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

c2d_startup_script 'alfresco'