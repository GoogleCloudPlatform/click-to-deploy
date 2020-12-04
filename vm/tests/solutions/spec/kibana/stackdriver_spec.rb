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

describe 'Installed Stackdriver Logging' do
  describe package('google-fluentd') do
    it { should be_installed }
  end

  describe package('google-fluentd-catch-all-config') do
    it { should be_installed }
  end

  describe service('google-fluentd.service'), :if => os[:family] == 'debian' do
    it { should be_enabled }
    it { should be_running }
  end
end

describe 'Installed Stackdriver Monitoring' do
  describe package('stackdriver-agent') do
    it { should be_installed }
  end

  describe service('stackdriver-agent.service'), :if => os[:family] == 'debian' do
    it { should be_enabled }
    it { should be_running }
  end
end
