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

default['discourse']['version'] = '2.8.2'
default['discourse']['src']['sha256'] = ''

default['discourse']['ruby']['version'] = '2.7.2'
default['discourse']['bundler']['version'] = '~>2.2'

default['discourse']['packages'] = [
  'build-essential',
  'libssl-dev',
  'libreadline-dev',
  'gcc',
  'libxslt-dev',
  'libxml2-dev',
  'zlib1g-dev',
  'libpq-dev',
  'imagemagick',
  'redis-server',
  'optipng',
  'pngquant',
  'jhead',
  'jpegoptim',
  'gifsicle',
  'git',
  'expect',
  'autoconf',
  'nginx-common',
  'libpcre3',
  'libpcre3-dev',
  'zlib1g',
  'zlib1g-dev',
]
