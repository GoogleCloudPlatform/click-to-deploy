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

# https://www.odoo.com/documentation/15.0/administration/install/install.html#

default['odoo']['packages'] = [
    'python3-pip',
    'build-essential',
    'python3-dev',
    'python3-venv',
    'python3-wheel',
    'libxslt-dev',
    'libzip-dev',
    'libldap2-dev',
    'libsasl2-dev',
    'python3-setuptools',
    'node-less',
    'fonts-noto-cjk',
    'python3-pyldap',
    'python3-qrcode',
    'python3-renderpm',
    'python3-setuptools',
    'python3-vobject',
    'python3-watchdog',
    'libssl-dev',
    'git',
]

default['odoo']['pip-packages'] = 'vobject qrcode pyldap num2words xlwt pyopenssl sslcrypto'

default['odoo']['version'] = '15.0'
default['odoo']['release'] = '20211201'
default['odoo']['sha256'] = 'a5c974da075e91f59a4331557b70a36865a2271148349db58e0064b20c972538'
default['odoo']['src']['sha256'] = '2a14b4c4d84e0380a354ae542af04e3b46c38ab3184406187be27c4d2972e623'

default['odoo']['wkhtmltopdf']['version'] = '0.12.6'
default['odoo']['wkhtmltopdf']['release'] = '0.12.6-1'
default['odoo']['wkhtmltopdf']['sha256'] = '3e7a93a2ae4a2dd5cccb1b7bcce0eb462c75f05efa314a29499dadfdc5ebc59e'
