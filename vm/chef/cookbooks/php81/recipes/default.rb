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



bash 'Setup Repo' do
  user 'root'
  code <<-EOH
    wget -O /etc/apt/trusted.gpg.d/php.gpg https://packages.sury.org/php/apt.gpg
EOH
end

apt_repository 'php' do
  uri 'https://packages.sury.org/php/'
  # key 'https://packages.sury.org/php/apt.gpg'
  distribution node['php81']['distribution']
  components ['main']
end

apt_update do
  action :update
end

package 'install packages' do
  package_name node['php81']['packages']
  action :install
  retries 5
  retry_delay 20
end

node['php81']['modules'].each do |pkg|
  include_recipe "php81::module_#{pkg}"
end
