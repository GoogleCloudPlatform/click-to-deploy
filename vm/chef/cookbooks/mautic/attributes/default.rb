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

default['mautic']['packages'] = [
    'libicu-dev',
    'libxmlrpc-epi0',
    'libxslt1.1',
    'libzip4',
    'php7.4-bcmath',
    'php7.4-gmp',
    'php7.4-imap',
]

default['mautic']['version'] = '4.4.10'
default['mautic']['user'] = 'www-data'
default['mautic']['db']['name'] = 'mautic'
