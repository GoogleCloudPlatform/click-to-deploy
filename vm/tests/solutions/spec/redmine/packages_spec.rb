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

describe package('ruby-dev') do
  it { should be_installed }
end

# AGPL license
describe package('ghostscript') do
  it { should_not be_installed }
end

# AGPL license
describe package('libgs9') do
  it { should_not be_installed }
end

# AGPL license
describe package('libgs9-common') do
  it { should_not be_installed }
end

# AGPL license
describe package('libjbig2dec0') do
  it { should_not be_installed }
end
