# Copyright 2024 Google LLC
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
# Reference: https://solr.apache.org/guide/solr/latest/deployment-guide/taking-solr-to-production.html

include_recipe 'apache2'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'openjdk11'
include_recipe 'solr::ospo'

package 'install_packages' do
  package_name node['solr']['packages']
  action :install
end

# Download sha512 checksum from apache
remote_file '/tmp/solr-checksum.sha512' do
  source "https://archive.apache.org/dist/solr/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz.sha512"
  action :create
end

# Download solr from apache
remote_file "/tmp/solr-#{node['solr']['version']}.tgz" do
  source "https://archive.apache.org/dist/solr/solr/#{node['solr']['version']}/solr-#{node['solr']['version']}.tgz"
  verify 'sed -i -e "s/ .*//; s=$=  %{path}=" /tmp/solr-checksum.sha512 && sha512sum -c /tmp/solr-checksum.sha512'
  action :create
end

# Untar the file and run the installer script with defaults (defined in the reference guide above)
bash 'configure_solr' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
    tar xzf solr-#{node['solr']['version']}.tgz solr-#{node['solr']['version']}/bin/install_solr_service.sh --strip-components=2
    ./install_solr_service.sh solr-#{node['solr']['version']}.tgz
    echo 'SOLR_OPTS="$SOLR_OPTS -Djetty.host=localhost"' >> /etc/default/solr.in.sh
EOH
end

template '/etc/apache2/conf-available/solr.conf' do
  source 'solr-conf.erb'
  owner 'root'
  group 'root'
  mode '0644'
end

execute 'enable_apache_modules' do
  command 'a2enmod headers proxy proxy_http'
end

execute 'enable-solr-config' do
  command 'a2enconf solr'
end

service 'apache2' do
  action [ :enable, :restart ]
end

# Replace configs on VM with those that support password authentcation on
# admin page.
cookbook_file '/var/solr/data/security.json' do
  source 'security.json'
  owner 'solr'
  group 'solr'
  mode '0640'
  action :create
end

# Drop shell script to adjust memory usage & set password for admin page
c2d_startup_script 'solr' do
  source 'solr.erb'
  action :template
end
