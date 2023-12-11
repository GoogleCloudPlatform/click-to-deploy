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

require 'spec_helper'

describe service('mariadb'), :if => os[:family] == 'debian' do
  it { should be_enabled }
  it { should be_running }
end

describe service('nginx'), :if => os[:family] == 'debian' do
  it { should be_enabled }
  it { should be_running }
end

describe service('redis-server'), :if => os[:family] == 'debian' do
  it { should be_enabled }
  it { should be_running }
end

describe service('frappe-bench-redis:frappe-bench-redis-cache') do
  it { should be_running.under('supervisor') }
end

describe service('frappe-bench-redis:frappe-bench-redis-queue') do
  it { should be_running.under('supervisor') }
end

describe service('frappe-bench-web:frappe-bench-node-socketio') do
  it { should be_running.under('supervisor') }
end

describe service('frappe-bench-web:frappe-bench-frappe-web') do
  it { should be_running.under('supervisor') }
end

describe service('frappe-bench-web:frappe-bench-node-socketio') do
  it { should be_running.under('supervisor') }
end

describe service('frappe-bench-workers:frappe-bench-frappe-schedule') do
  it { should be_running.under('supervisor') }
end
