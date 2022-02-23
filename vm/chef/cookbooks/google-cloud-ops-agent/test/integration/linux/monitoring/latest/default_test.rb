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

describe service('stackdriver-agent') do
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

describe file('/etc/stackdriver/collectd.conf') do
  if node['package_state'] == 'present'
    it { should exist }

    # When custom config is set, ensure the file was placed correctly
    # For CI this is test/integration/linux/monitoring/config/collectd.conf
    if node['main_config'] != ''
      its('owner') { should eq 'root' }
      its('group') { should eq 'root' }
      its('sha256sum') { should eq '14050e7ae0d30867a005007e015b9a9ab570f74a15fa6ccbaae4e4707195495c' }
    end
  end
end

if node['package_state'] == 'present' && node['additional_config_dir'] != ''
  # When additional_config_dir is set, ensure the files are placed correctly
  # For CI this is test/integration/linux/monitoring/config/plugins/example_plugin.conf
  describe file('/etc/stackdriver/collectd.d/example_plugin.conf') do
    it { should exist }
    its('owner') { should eq 'root' }
    its('group') { should eq 'root' }
    its('sha256sum') { should eq 'c05d2f664052abaaadb1b1baa9807fa6fd3c2ed9b419575671c911ecb7d3dd3c' }
  end
end
