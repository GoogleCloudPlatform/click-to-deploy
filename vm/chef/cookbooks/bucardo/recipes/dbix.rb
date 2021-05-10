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

remote_file '/tmp/dbix.tar.gz' do
  source 'http://bucardo.org/downloads/dbix_safe.tar.gz'
  action :create
end

bash 'Extract DBIX' do
  cwd '/tmp'
  code <<-EOH
    mkdir -p dbix/ \
      && tar xvfz dbix.tar.gz -C dbix/ --strip-components=1
EOH
end

bash 'Install DBIX' do
  cwd '/tmp/dbix'
  code <<-EOH
    perl Makefile.PL \
      && make \
      && make test \
      && make install
EOH
end
