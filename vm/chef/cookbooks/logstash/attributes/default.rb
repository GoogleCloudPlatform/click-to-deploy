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

default['logstash']['version'] = '7.8.1'

default['logstash']['release'] =
  default['logstash']['version'].split('.')[0]

default['logstash']['repository_url'] =
  "https://artifacts.elastic.co/packages/#{default['logstash']['release']}.x/apt"
default['logstash']['keyserver_url'] =
  'https://artifacts.elastic.co/GPG-KEY-elasticsearch'

default['jruby']['version'] = '9.2.13.0'
