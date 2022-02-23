# Copyright:: 2021 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Read node attributes
node = json('/tmp/kitchen/dna.json').params

describe service('google-fluentd') do
  if node['package_state'] == 'present'
    it { should be_installed }
    it { should be_enabled }
    it { should be_running }
  else
    it { should_not be_installed }
    it { should_not be_enabled }
    it { should_not be_running }
  end
end

describe file('/etc/google-fluentd/google-fluentd.conf') do
  if node['package_state'] == 'present'
    it { should exist }

    # When custom config is set, ensure the file was placed correctly
    # For CI this is test/integration/linux/logging/config/google-fluentd.conf
    if node['main_config'] != ''
      its('owner') { should eq 'root' }
      its('group') { should eq 'root' }
      its('sha256sum') { should eq '633492a8b40166009a06c7a495df2f08c24ed6c050554e67827e368ba27b6d4c' }
    end
  end
end

if node['package_state'] == 'present' && node['additional_config_dir'] != ''
  # When additional_config_dir is specified, ensure that files are placed correctly
  # For CI this is test/integration/linux/logging/config/plugins/custom_config.conf
  describe file('/etc/google-fluentd/plugin/custom_config.conf') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('sha256sum') { should eq '203773873a0bccc50d2bc52a1dec9231a39c0d2091ef6c5f2875b82a5be68354' }
  end
end
