# Copyright 2024 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# https://www..com/documentation/15.0/administration/install/install.html#

default['odoo']['packages'] = [
    'python3-pip',
    'build-essential',
    'python3-dev',
    'python3-venv',
    'python3-wheel',
    'libzip-dev',
    'libldap2-dev',
    'libsasl2-dev',
    'python3-setuptools',
    'node-less',
    'fonts-noto-cjk',
    'fonts-inconsolata',
    'fonts-font-awesome',
    'fonts-roboto-unhinted',
    'gsfonts',
    'python3-pyldap',
    'python3-babel',
    'python3-cryptography',
    'python3-decorator',
    'python3-docutils',
    'python3-geoip2',
    'python3-gevent',
    'python3-greenlet',
    'python3-jinja2',
    'python3-libsass',
    'python3-markupsafe',
    'python3-num2words',
    'python3-ofxparse',
    'python3-openssl',
    'python3-passlib',
    'python3-gdbm',
    'python3-dev',
    'python3-pip',
    'python3-virtualenv',
    'virtualenv',
    'tesseract-ocr',
    'libtesseract-dev',
    'libleptonica-dev',
    'exim4',
    'uwsgi',
    'uwsgi-plugin-python3',
    'python3-polib',
    'python3-psutil',
    'python3-psycopg2',
    'python3-pydot',
    'python3-pypdf2',
    'python3-reportlab',
    'python3-rjsmin',
    'python3-serial',
    'python3-stdnum',
    'python3-usb',
    'python3-xlrd',
    'python3-werkzeug',
    'python3-xlsxwriter',
    'python3-xlwt',
    'python3-qrcode',
    'python3-renderpm',
    'python3-zeep',
    'python3-freezegun',
    'python3-setuptools',
    'python3-vobject',
    'python3-watchdog',
    'libssl-dev',
    'git',

]

default['odoo']['pip-packages'] = 'vobject qrcode pyldap num2words xlwt pyopenssl sslcrypto'

default['odoo']['version'] = '18.0'
default['odoo']['release'] = '20241107'
default['odoo']['sha256'] = '212a79485ed39c628060e83853f3d1067ca57b4b8a86f2b0e73b9d56ff766de9'
default['odoo']['src']['sha256'] = '615df6b6fc15f0120b7b301e792aa76e80bd0c2c86fd690b9d6ef6dfc588b30a'

default['odoo']['wkhtmltopdf']['version'] = '0.12.6'
default['odoo']['wkhtmltopdf']['release'] = '0.12.6-1'
default['odoo']['wkhtmltopdf']['sha256'] = '3e7a93a2ae4a2dd5cccb1b7bcce0eb462c75f05efa314a29499dadfdc5ebc59e'
