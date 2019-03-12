# Copyright 2018 Google LLC
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

include_recipe 'c2d-config::default'
include_recipe 'apache2::default'
include_recipe 'apache2::rm-index'
include_recipe 'apache2::security-config'

# install zabbix package
bash 'install zabbix' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  wget https://repo.zabbix.com/zabbix/#{node['zabbix']['version']}/debian/pool/main/z/zabbix-release/zabbix-release_#{node['zabbix']['release']}+stretch_all.deb
  dpkg -i zabbix-release_#{node['zabbix']['release']}+stretch_all.deb
  apt-get update
EOH
end

package 'install packages' do
  package_name node['zabbix']['packages']
  action :install
end

# configure additional locales (not all available)
bash 'enable additional locales' do
  user 'root'
  cwd '/tmp'
  code <<-EOH
  sed -i '/zh_CN.UTF-8/ s/^# //' /etc/locale.gen
  sed -i '/fr_FR.UTF-8/ s/^# //' /etc/locale.gen
  sed -i '/it_IT.UTF-8/ s/^# //' /etc/locale.gen
  sed -i '/pl_PL.UTF-8/ s/^# //' /etc/locale.gen
  sed -i '/ru_RU.UTF-8/ s/^# //' /etc/locale.gen
  locale-gen
EOH
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
  su - postgres -c 'createdb -O zabbix zabbix'

  zcat /usr/share/doc/zabbix-server-pgsql/create.sql.gz | sudo -u zabbix psql zabbix

  ### for PostgreSQL -- uses socket (localhost uses tcp)
  sed -i '/^# DBHost=localhost/ a \
\
DBHost=' /etc/zabbix/zabbix_server.conf

  sed -i 's/# ListenIP=127.0.0.1/ListenIP=127.0.0.1/' /etc/zabbix/zabbix_server.conf

EOH
end

# put guest user into Disabled group
bash 'configure zabbix' do
  user 'postgres'
  cwd '/tmp'
  code <<-EOH
  disabledgrpid=$(psql -Upostgres -qtAX -d zabbix -c "select usrgrpid from usrgrp where name='Disabled'")
  guestuserid=$(psql -Upostgres -qtAX -d zabbix -c "select userid from users where alias='guest'")
  lastgroupid=$(psql -Upostgres -qtAX -d zabbix -c "select id from users_groups order by id desc limit 1")
  ((lastgroupid++))
  psql -Upostgres -qtAX -d zabbix -c "insert into users_groups (id,usrgrpid,userid) values ($lastgroupid,$disabledgrpid,$guestuserid)"
EOH
end

template '/etc/zabbix/web/zabbix.conf.php' do
  source 'etc-zabbix-web-zabbix-conf-php.erb'
  cookbook 'zabbix'
  owner 'root'
  group 'root'
  mode '0644'
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
