# Copyright 2019 Google LLC
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
    'libssl1.0-dev',
    'git',
]

default['odoo']['pip-packages'] = 'vobject qrcode pyldap num2words'

# Notice for future update to version 13:
# The 13.0 version requires python 3.6+ and xlwt pip-package

default['odoo']['version'] = '12.0'
default['odoo']['release'] = '20200922'
default['odoo']['sha256'] = 'd84d1385822a034755cd3bfe01c917dc96c2db6b4a357dea2ec3b9c7d1e4bc91'
default['odoo']['src']['sha256'] = '7418008825f02b5b0dfcd4b16d5b73b97bdb0f670bfb21809e8b3372fb1ac924'

default['odoo']['wkhtmltopdf']['version'] = '0.12.5'
default['odoo']['wkhtmltopdf']['release'] = '0.12.5-1'
default['odoo']['wkhtmltopdf']['sha256'] = '1140b0ab02aa6e17346af2f14ed0de807376de475ba90e1db3975f112fbd20bb'
