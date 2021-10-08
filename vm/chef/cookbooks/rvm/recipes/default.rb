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

apt_update 'update'

package 'install packages' do
  only_if { platform?('debian') && node['platform_version'].to_i >= 10 }
  package_name node['rvm']['packages']
  action :install
  retries 5
  retry_delay 60
end

bash 'Install keys for RVM' do
  cwd '/tmp/'
  user 'root'
  code <<-EOH
    curl -sSL https://rvm.io/mpapis.asc | gpg2 --import -
    curl -sSL https://rvm.io/pkuczynski.asc | gpg2 --import -
EOH
end

bash 'Install RVM' do
  cwd '/tmp/'
  user 'root'
  code <<-EOH
    PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin su -c '\
      curl -sSL https://get.rvm.io | bash -s stable --rails --with-gems="bundler,rb-inotify"'
EOH
end
