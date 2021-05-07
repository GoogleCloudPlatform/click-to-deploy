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

describe 'C2D startup config' do
  describe service('google-c2d-startup.service') do
    it { should be_enabled }
  end

  describe file('/var/lock/google_vm_config.lock') do
    it { should_not exist }
  end
end

describe 'C2D startup scripts should exists' do
  describe file('/opt/c2d/scripts/00-manage-swap') do
    it { should exist }
  end

  describe file('/opt/c2d/scripts/01-wildfly') do
    it { should exist }
  end
end
