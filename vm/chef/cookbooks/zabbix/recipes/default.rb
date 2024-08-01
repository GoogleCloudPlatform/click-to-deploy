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

node.override['postgresql']['standalone']['allow_external'] = false

include_recipe 'c2d-config::default'
include_recipe 'openssh'
include_recipe 'apache2::default'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'
include_recipe 'postgresql::standalone_bookworm'
include_recipe 'zabbix::ospo'

# install zabbix package
apt_repository 'zabbix' do
  uri node['zabbix']['repo']['uri']
  components node['zabbix']['repo']['components']
  distribution node['zabbix']['repo']['distribution']
  key node['zabbix']['repo']['keyserver']
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end

package 'install packages' do
  package_name node['zabbix']['packages']
  action :install
end

# configure zabbix
bash 'configure zabbix' do
  user 'root'
  cwd '/tmp'
  code <<-EOH

  sed -i 's/# php_value date.timezone/php_value date.timezone/' /etc/apache2/conf-enabled/zabbix.conf
  sed -i '1 i\
RedirectMatch ^/$ /zabbix/
' /etc/apache2/conf-enabled/zabbix.conf

  a2enmod cgi ssl
  a2dissite 000-default
  a2ensite default-ssl

  su - postgres -c 'createuser zabbix'
  su - postgres -c 'createdb -O zabbix -E Unicode zabbix'
  su - postgres -c 'createdb -O zabbix -E Unicode zabbix_proxy'

  zcat /usr/share/zabbix-sql-scripts/postgresql/server.sql.gz | sudo -u zabbix psql zabbix
  cat /usr/share/zabbix-sql-scripts/postgresql/proxy.sql | sudo -u zabbix psql zabbix_proxy

  ### for PostgreSQL -- uses socket (localhost uses tcp)
  sed -i 's/^# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_server.conf

  sed -i 's/# ListenIP=0.0.0.0/ListenIP=127.0.0.1/' /etc/zabbix/zabbix_server.conf

  sed -i 's/^# DBHost=localhost/DBHost=localhost/' /etc/zabbix/zabbix_proxy.conf

  sed -i 's/# ListenPort=10051/ListenPort=10055/' /etc/zabbix/zabbix_proxy.conf

EOH
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'etc-zabbix-web-zabbix-conf-php.erb'
  cookbook 'zabbix'
  owner 'root'
  group 'root'
  mode '0644'
end

template '/opt/c2d/zabbix-utils' do
  source 'zabbix-utils'
  owner 'root'
  group 'root'
  mode 0755
  action :create
end

service 'apache2' do
  action [ :enable, :restart ]
end

service 'zabbix-server' do
  action [ :enable, :stop ]
end

service 'zabbix-proxy' do
  action [ :enable, :stop ]
end

c2d_startup_script 'zabbix' do
  source 'opt-c2d-scripts-zabbix.erb'
  action :template
end
