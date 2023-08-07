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
# Reference: https://packages.sury.org/php/README.txt

apt_update do
  action :update
end

package 'install packages' do
  package_name node['php74']['dep_packages']
  action :install
end

bash 'Configure apt repo' do
  code <<-EOH
  curl -sSLo /usr/share/keyrings/deb.sury.org-php.gpg https://packages.sury.org/php/apt.gpg
  apt-key adv --fetch-keys 'https://packages.sury.org/php/apt.gpg' > /dev/null 2>&1
  sh -c 'echo "deb [signed-by=/usr/share/keyrings/deb.sury.org-php.gpg] https://packages.sury.org/php/ $(lsb_release -sc) main" > /etc/apt/sources.list.d/php.list'
EOH
end

apt_update do
  action :update
end

package 'install packages' do
  package_name node['php74']['packages']
  action :install
end

node['php74']['modules'].each do |pkg|
  include_recipe "php74::module_#{pkg}"
end
