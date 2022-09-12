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

default['elasticsearch']['version'] = '7.10.2'

default['elasticsearch']['release'] =
  default['elasticsearch']['version'].split('.')[0]

default['elasticsearch']['repo']['url'] =
  "https://artifacts.elastic.co/packages/#{default['elasticsearch']['release']}.x/apt"
default['elasticsearch']['repo']['distribution'] = 'stable'
default['elasticsearch']['repo']['components'] = ['main']
default['elasticsearch']['repo']['keyserver'] =
  'https://artifacts.elastic.co/GPG-KEY-elasticsearch'

default['elasticsearch']['packages'] = ['apt-transport-https', 'unzip']
