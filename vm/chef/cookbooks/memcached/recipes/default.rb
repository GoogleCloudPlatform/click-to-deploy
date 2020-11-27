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

apt_update do
  action :update
end

package 'install_memcached' do
  package_name node['memcached']['package']
  retries 5
  retry_delay 30
end

bash 'modify /etc/memcached.conf' do
  user 'root'
  code <<-EOH
    sed -i 's/-l 127.0.0.1/# -l 127.0.0.1/' /etc/memcached.conf
  EOH
end

c2d_startup_script 'memcached'
