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

default['odoo']['version'] = '16.0'
default['odoo']['release'] = '20230315'
default['odoo']['sha256'] = '941bebc8939aa6516b0ab596d9fcbc80ee50e26376f8b2908c0913ede598ff57'
default['odoo']['src']['sha256'] = '1058232165db2ab5fb088f7735567587ed12f2b80cdea832321db03246b1b322'

default['odoo']['wkhtmltopdf']['version'] = '0.12.6'
default['odoo']['wkhtmltopdf']['release'] = '0.12.6-1'
default['odoo']['wkhtmltopdf']['sha256'] = '3e7a93a2ae4a2dd5cccb1b7bcce0eb462c75f05efa314a29499dadfdc5ebc59e'
