# Copyright 2020 Google LLC
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

default['erpnext']['packages'] = [
    'build-essential',
    'git',
    'nginx',
    'python3-dev',
    'python3-pip',
    'python3-setuptools',
    'redis-server',
    'supervisor',
    'virtualenv',
    'wkhtmltopdf',
]

default['erpnext']['version'] = '12'
default['erpnext']['site'] = 'site1.local'

default['erpnext']['nodejs']['version'] = '12'

default['erpnext']['mariadb']['version'] = '1:10.3.*'
default['erpnext']['mariadb']['packages'] = [ 'mariadb-server', 'libmariadb-dev' ]

default['erpnext']['frappe']['bench'] = 'frappe-bench'
default['erpnext']['frappe']['user'] = 'frappe'
default['erpnext']['frappe']['password'] = `openssl rand -base64 12 | fold -w 12 | head -n1 | tr -d '\r\n'`

default['erpnext']['mysql-root-password'] = `openssl rand -base64 12 | fold -w 12 | head -n1 | tr -d '\r\n'`
default['erpnext']['erpnext-admin-password'] = `openssl rand -base64 12 | fold -w 12 | head -n1 | tr -d '\r\n'`
