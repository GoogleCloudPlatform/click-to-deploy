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

require 'spec_helper'

describe 'Docker-compose should exists' do
  describe file('/usr/local/bin/docker-compose') do
    it { should exist }
    it { should be_executable }
  end

  describe command('/usr/local/bin/docker-compose version') do
    its(:exit_status) { should eq 0 }
    its(:stdout) { should match(/Docker Compose version v[0-9]+\.[0-9]+\.[0-9]+/) }
  end

  describe file('/opt/redash/nginx/default.conf') do
    it { should exist }
  end

  describe file('/opt/redash/setup/docker-compose.yml') do
    it { should exist }
    its(:content) { should match(/image:\s+nginx:1\.30\.7-alpine/) }
    its(:content) { should include '/opt/redash/nginx/default.conf:/etc/nginx/conf.d/default.conf:ro' }
    its(:content) { should_not match(%r{image:\s+redash/nginx}) }
  end
end
