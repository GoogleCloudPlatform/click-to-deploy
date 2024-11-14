# Copyright 2023 Google LLC
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

default['weblate']['version'] = '5.8.2'
default['weblate']['db']['name'] = 'weblate'
default['weblate']['pip-packages'] = [
  'psycopg2-binary',
  'ruamel.yaml',
  'aeidon',
  'boto3',
  'zeep',
  'chardet',
  'tesserocr',
  'python-ldap',
  'xmlsec',
].join(' ')

default['weblate']['packages'] = [
  'gettext-base',
  'libxml2-dev',
  'libxslt-dev',
  'libsasl2-dev',
  'libldap2-dev',
  'libfreetype6-dev',
  'libjpeg-dev',
  'libz-dev',
  'libxmlsec1-dev',
  'libyaml-dev',
  'libffi-dev',
  'libcairo-dev',
  'gir1.2-pango-1.0',
  'libgirepository1.0-dev',
  'libacl1-dev',
  'libssl-dev',
  'build-essential',
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
  'git',
  'wget',
]
