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

default['cassandra']['version'] = '5.0.2'
default['cassandra']['apt_version'] = "#{default['cassandra']['version']}.*"

default['cassandra']['repo']['uri'] = 'https://debian.cassandra.apache.org'
default['cassandra']['repo']['components'] = ['main']
default['cassandra']['repo']['distribution'] = '50x'
default['cassandra']['repo']['keyserver'] = 'https://www.apache.org/dist/cassandra/KEYS'
