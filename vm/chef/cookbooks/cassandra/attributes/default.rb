# Copyright 2018 Google LLC
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

# Remember to check if repo component update
# is needed when changing the version.
default['cassandra']['version'] = '3.11.4'

default['cassandra']['repo']['uri'] = 'http://www.apache.org/dist/cassandra/debian'
default['cassandra']['repo']['components'] = ['311x', 'main']
default['cassandra']['repo']['keyserver'] = 'https://www.apache.org/dist/cassandra/KEYS'
