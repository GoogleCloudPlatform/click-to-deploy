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

default['redmine']['packages'] = [
  'build-essential',
  'libmysqlclient-dev',
  'ruby-bundler',
  'ruby-dev',
  'zlib1g-dev',
  'libapache2-mod-passenger',
]
default['redmine']['agpl_packages'] = [
  'ghostscript',
  'libgs9',
  'libgs9-common',
  'libjbig2dec0',
]
default['redmine']['version'] = '5.1.4'
default['redmine']['ruby']['version'] = '3.2.3'

# OS Settings
default['redmine']['user'] = 'redmine'

# DB Settings
default['redmine']['db']['user'] = 'redmineuser'
default['redmine']['db']['name'] = 'redmine'
