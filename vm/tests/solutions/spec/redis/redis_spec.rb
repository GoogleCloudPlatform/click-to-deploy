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

require 'spec_helper'

describe file('/usr/src/redis') do
  it { should be_directory }
end

describe file('/var/log/redis') do
  it { should be_directory }
end

describe file('/var/lib/redis') do
  it { should be_directory }
end

describe file('/etc/redis') do
  it { should be_directory }
end

describe file('/etc/redis/redis.conf') do
  it { should exist }
end

describe file('/etc/redis/redis_node.conf') do
  it { should exist }
end

describe file('/etc/systemd/system/redis-server.service') do
  it { should exist }
end

describe file('/etc/systemd/system/redis-sentinel.service') do
  it { should exist }
end
