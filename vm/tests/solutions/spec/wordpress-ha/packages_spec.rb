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

describe package('mysql-client') do
  it { should be_installed }
end

# WordPress HA doesn't need mysql-server as it uses Cloud SQL.
describe package('mysql-server') do
  it { should_not be_installed }
end

describe package('apache2') do
  it { should be_installed }
end

describe package('libapache2-mod-php7.0') do
  it { should be_installed }
end

describe package('php7.0-fpm') do
  it { should be_installed }
end

describe package('php7.0-xml') do
  it { should be_installed }
end

describe package('php7.0-mysql') do
  it { should be_installed }
end

describe package('php7.0-mysql') do
  it { should be_installed }
end
