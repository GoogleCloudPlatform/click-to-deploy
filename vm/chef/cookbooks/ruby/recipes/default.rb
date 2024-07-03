# Copyright 2021 Google LLC
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

package 'install packages' do
  package_name node['ruby']['packages']
  action :install
end

remote_file '/tmp/ruby.tar.gz' do
  source "https://cache.ruby-lang.org/pub/ruby/#{node['ruby']['major']}.#{node['ruby']['minor']}/ruby-#{node['ruby']['version']}.tar.gz"
  action :create
end

bash 'unpackage ruby, compile ruby, and install ruby' do
  user 'root'
  environment({
    'version' => node['ruby']['version'],
  })
  code <<-EOH
    tar -xzf /tmp/ruby.tar.gz -C /tmp/
    cd "/tmp/ruby-${version}"
    ./configure
    make
    make install
EOH
end
