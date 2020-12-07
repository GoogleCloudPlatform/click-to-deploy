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

default['mysql']['packages'] = ['mysql-server', 'mysql-client', 'wget']

default['mysql']['bind_address'] = 'localhost'

# Reference: https://dev.mysql.com/downloads/repo/apt/
default['mysql']['apt']['file'] = 'mysql-apt-config_0.8.16-1_all.deb'
default['mysql']['apt']['md5'] = 'f6a7c41f04cc4fea7ade285092eea77a'
default['mysql']['apt']['url'] = "https://dev.mysql.com/get/#{node['mysql']['apt']['file']}"
