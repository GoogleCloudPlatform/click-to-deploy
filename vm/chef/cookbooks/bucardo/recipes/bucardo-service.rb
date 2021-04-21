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

include_recipe 'bucardo::default'

remote_file '/tmp/bucardo.tar.gz' do
  source "http://bucardo.org/downloads/Bucardo-#{node['bucardo']['version']}.tar.gz"
  action :create
end

bash 'Install Buscardo Service' do
  cwd '/tmp'
  code <<-EOH
    mkdir -p bucardo/ \
    && tar xvfz bucardo.tar.gz  -C bucardo/ --strip-components=1 \
    && cd bucardo/ \
    && perl Makefile.PL \
    && make install \
    && mkdir /var/run/bucardo \
    && chmod 777 /var/run/bucardo
EOH
end
