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

default['dreamfactory']['version'] = '6.3.0'
default['dreamfactory']['db']['name'] = 'dreamfactory'
default['dreamfactory']['packages'] = [
  'git',
  'curl',
  'cron',
  'zip',
  'unzip',
  'ca-certificates',
  'apt-transport-https',
  'lsof',
  'mcrypt',
  'libmcrypt-dev',
  'libreadline-dev',
  'wget',
  'sudo',
  'nginx',
  'build-essential',
  'unixodbc-dev',
  'gcc',
  'cmake',
  'jq',
  'libaio1',
  'php-pear',
]

default['php81']['distribution'] = 'bookworm'
