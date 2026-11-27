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

describe 'Hide PHP Version' do
  describe file('/etc/php/8.3/apache2/php.ini') do
    its(:content) { should match /^expose_php = Off$/ }
  end

  describe command('curl -I http://localhost') do
    its(:stdout) { should_not match /X-Powered-By:/ }
  end
end

describe 'PHP 8.3 Version' do
  describe package('libapache2-mod-php8.3') do
    it { should be_installed }
  end

  describe package('libapache2-mod-php8.1') do
    it { should_not be_installed }
  end

  describe command("dpkg --compare-versions \"$(dpkg-query -W -f='${Version}' php8.3-common)\" ge 8.3.37") do
    its(:exit_status) { should eq 0 }
  end
end
