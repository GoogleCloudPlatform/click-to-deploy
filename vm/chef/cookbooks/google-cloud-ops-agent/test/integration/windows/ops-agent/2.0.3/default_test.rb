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
node = json('$env:TEMP\kitchen\dna.json').params

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

describe file('C:\Program Files\Google\cloud Operations\Ops Agent\config\config.yaml') do
  if node['package_state'] == 'present'
    it { should exist }
    its('sha256sum') { should eq 'a8dd6a4312fb2d62aa11bccd612182033fd1b378b9bc6da8eef25cee54b15dd3' }
  end
end
