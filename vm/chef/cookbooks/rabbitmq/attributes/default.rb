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

default['rabbitmq']['deps_packages'] = ['gnupg2', 'apt-transport-https', 'curl', 'wget', 'libncurses5']
default['rabbitmq']['license_url'] = 'https://raw.githubusercontent.com/rabbitmq/rabbitmq-server/master/LICENSE-MPL-RabbitMQ'
default['rabbitmq']['packages'] = [
  'erlang-base',
  'erlang-asn1',
  'erlang-crypto',
  'erlang-eldap',
  'erlang-ftp',
  'erlang-inets',
  'erlang-mnesia',
  'erlang-os-mon',
  'erlang-parsetools',
  'erlang-public-key',
  'erlang-runtime-tools',
  'erlang-snmp',
  'erlang-ssl',
  'erlang-syntax-tools',
  'erlang-tftp',
  'erlang-tools',
  'erlang-xmerl',
  'rabbitmq-server',
]

default['rabbitmq']['apt']['lsb_codename'] = 'bullseye'
default['rabbitmq']['apt']['components'] = ['main']
default['rabbitmq']['apt']['keyserver'] = 'hkps://keys.openpgp.org'
default['rabbitmq']['apt']['uri'] = 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/deb/debian'
default['rabbitmq']['apt']['key'] = 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-server/gpg.9F4587F226208342.key'

default['rabbitmq']['erlang']['apt']['uri'] = 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/deb/debian'
default['rabbitmq']['erlang']['apt']['key'] = 'https://dl.cloudsmith.io/public/rabbitmq/rabbitmq-erlang/gpg.E495BB49CC4BBE5B.key'
