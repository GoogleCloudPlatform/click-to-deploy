# Copyright 2022 Google LLC
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

default['c2d-config']['common-packages'] = [
  'apt-transport-https',
  'jq',
  'vim',
  'less',
  'host',
  'xfsprogs',
]

default['c2d-config']['base-dir'] = '/opt/c2d'
default['c2d-config']['config-dir'] = "#{node['c2d-config']['base-dir']}/etc"
