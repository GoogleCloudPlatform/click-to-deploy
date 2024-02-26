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

default['ruby']['packages'] = ['gcc', 'libssl-dev', 'libyaml-dev', 'make', 'zlib1g-dev']
default['ruby']['version'] = '3.2.2'
default['ruby']['major'] = node['ruby']['version'][0]
default['ruby']['minor'] = node['ruby']['version'].split('.')[1]
