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

default['mautic']['packages'] = [
    'libicu64',
    'libxmlrpc-epi0',
    'libxslt1.1',
    'libzip4',
    'php7.3-bcmath',
    'php7.3-gmp',
    'php7.3-imap',
]

default['mautic']['version'] = '3.0'
default['mautic']['user'] = 'www-data'
default['mautic']['db']['name'] = 'mautic'
