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

describe service('google-cloud-ops-agent') do
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

describe package('google-cloud-ops-agent') do
  if node['package_state'] == 'present'
    it { should be_installed }
    # This code will break, if 2.x.x is ever released
    its('version') { should match /2./ }
  else
    it { should_not be_installed }
  end
end

describe file('/etc/google-cloud-ops-agent/config.yaml') do
  if node['package_state'] == 'present'
    it { should exist }

    # When custom config is set, ensure the file was placed correctly
    # For CI this is test/integration/linux/ops-agent/config/config.yaml
    if node['main_config'] != ''
      its('owner') { should eq 'root' }
      its('group') { should eq 'root' }
      its('sha256sum') { should eq 'f360e2ac0984bf33f7e158263ce5ea68c363680af80237558173284f3b47f337' }
    end
  end
end
