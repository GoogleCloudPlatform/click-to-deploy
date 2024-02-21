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
#
# MySQL v8.0 installation and configuration recipe

include_recipe 'mysql::install-mysql-apt-config'

bash 'configure mysql-apt-config v8.0' do
  user 'root'
  code <<-EOH
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-server select mysql-8.0'
  debconf-set-selections <<< 'mysql-apt-config mysql-apt-config/select-product: select Ok'
  DEBIAN_FRONTEND=noninteractive dpkg-reconfigure mysql-apt-config
EOH
end

apt_update 'update' do
  action :update
  retries 5
  retry_delay 30
end
