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

node.override['postgresql']['standalone']['allow_external'] = false

include_recipe 'openjdk11'
include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'postgresql::standalone_bullseye'

# Notes:
# 1) This recipe adds two new entries to /etc/hosts - pointing hostname to
#    local ips; see alse:
#    http://blog.itdhq.com/post/133135613685/alfresco-sdk-fixing-mysteriously-slow-tomcat
# 2) This recipe provides custom setenv.sh script for Alfresco Tomcat -
#    this is related to slow Alfresco startup; see also:
#    https://wiki.apache.org/tomcat/HowTo/FasterStartUp#Entropy_Source

# Copy Alfresco installation configuration:
template '/tmp/install-opts' do
  source 'install-opts.erb'
  owner 'root'
  group 'root'
  mode '0640'
end

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

apt_package 'wget' do
  action :install
end

bash 'download_and_check_alfresco' do
  code <<-EOH
    wget --no-check-certificate $alfresco_install_url -O /tmp/alfresco.bin
    echo "$alfresco_sha256 /tmp/alfresco.bin" | sha256sum -c
    chmod u+x /tmp/alfresco.bin
EOH
  environment({
    'alfresco_install_url' => node['alfresco']['install']['url'],
    'alfresco_sha256' => node['alfresco']['install']['sha256'],
  })
end

# Install Alfresco with pre-defined options
execute 'install_alfresco' do
  command '/tmp/alfresco.bin --optionfile /tmp/install-opts'
end

# Configure Apache to serve as Alfresco proxy:
template '/etc/apache2/sites-available/alfresco.conf' do
  source 'alfresco.conf.erb'
  owner 'root'
  group 'root'
  mode '0640'
end

bash 'enable_alfresco_site_on_apache' do
  code <<-EOH
    a2enmod proxy proxy_http rewrite
    a2dissite 000-default
    a2ensite alfresco
EOH
end

service 'apache2' do
  action :restart
end

# Set environment variables for Alfresco's tomcat with new configuration script
execute 'move_original_setenv_file' do
  cwd '/opt/alfresco/tomcat/bin'
  command 'mv setenv.sh setenv.sh.orig'
end

template '/opt/alfresco/tomcat/bin/setenv.sh' do
  source 'setenv.sh.erb'
  owner 'root'
  group 'root'
  mode '0640'
end

# Copy alfresco-global.properties template configuration file (to override):
template '/opt/alfresco/alfresco-global.properties.template' do
  source 'alfresco-global.properties.template.erb'
  owner 'root'
  group 'root'
  mode '0640'
end

# Prepare Alfresco to be run as service
template '/etc/init.d/alfresco' do
  source 'alfresco.service.erb'
  owner 'root'
  group 'root'
  mode '0755'
end

# Copy post-deploy configuration script
# (to override and configure instance's specific passwords):
c2d_startup_script 'alfresco'

# Download source code
include_recipe 'alfresco::download_source_code'
