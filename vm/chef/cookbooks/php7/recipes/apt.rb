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

remote_file '/tmp/dotdeb.gpg' do
  source 'https://www.dotdeb.org/dotdeb.gpg'
  action :create
end

file '/etc/apt/sources.list.d/dotdeb.list' do
  content 'deb http://packages.dotdeb.org jessie all'
  action :create
end

execute 'adding gpg key' do
  command 'apt-key add /tmp/dotdeb.gpg'
  action :run
end

execute 'updating php7 repo' do
  command 'apt-get update'
  action :run
end
