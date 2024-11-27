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

default['zabbix']['version'] = '7.0.6'
default['zabbix']['repo']['version'] = '7.0'
default['zabbix']['packages'] = %w(mailutils php-pgsql zabbix-server-pgsql zabbix-frontend-php zabbix-proxy-pgsql zabbix-sql-scripts zabbix-apache-conf php-gd php-bcmath php-mbstring php-xml php-ldap php-json)
default['zabbix']['repo']['uri'] = "https://repo.zabbix.com/zabbix/#{default['zabbix']['repo']['version']}/debian/"
default['zabbix']['repo']['components'] = ['main']
default['zabbix']['repo']['distribution'] = 'bookworm'
default['zabbix']['repo']['keyserver'] = 'https://repo.zabbix.com/zabbix-official-repo.key'
