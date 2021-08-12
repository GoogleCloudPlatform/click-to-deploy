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

apt_repository 'php' do
  uri 'https://packages.sury.org/php/'
  key 'https://packages.sury.org/php/apt.gpg'
  components ['main']
end

package 'install packages' do
  package_name node['php74']['packages']
  action :install
end

node['php74']['modules'].each do |pkg|
  include_recipe "php74::module_#{pkg}"
end
