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
#
# Install mysql-apt-config -- MySQL installation package

apt_package 'wget' do
  action :install
end

remote_file "/tmp/#{node['mysql']['apt']['file']}" do
  source node['mysql']['apt']['url']
  verify "echo '#{node['mysql']['apt']['md5']} %{path}' | md5sum -c"
end

package 'mysql-apt-config' do
  source "/tmp/#{node['mysql']['apt']['file']}"
  provider Chef::Provider::Package::Dpkg
end
