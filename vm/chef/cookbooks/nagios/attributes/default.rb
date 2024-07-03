# Copyright 2022 Google LLC
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

default['nagios']['core']['version'] = '4.4.9'
default['nagios']['plugins']['version'] = '2.2.1'
default['nagios']['nrpe']['version'] = '3.2.1'

default['nagios']['config']['adminuser'] = 'nagiosadmin'

default['nagios']['core']['dir'] = "nagios-#{node['nagios']['core']['version']}"
default['nagios']['core']['file'] = "#{node['nagios']['core']['dir']}.tar.gz"
default['nagios']['core']['url'] = "https://assets.nagios.com/downloads/nagioscore/releases/#{node['nagios']['core']['file']}"

default['nagios']['plugins']['dir'] = "nagios-plugins-#{node['nagios']['plugins']['version']}"
default['nagios']['plugins']['file'] = "#{node['nagios']['plugins']['dir']}.tar.gz"
default['nagios']['plugins']['url'] = "https://nagios-plugins.org/download/#{node['nagios']['plugins']['file']}"

default['nagios']['nrpe']['dir'] = "nrpe-#{node['nagios']['nrpe']['version']}"
default['nagios']['nrpe']['file'] = "#{node['nagios']['nrpe']['dir']}.tar.gz"
default['nagios']['nrpe']['url'] = "https://github.com/NagiosEnterprises/nrpe/releases/download/#{node['nagios']['nrpe']['dir']}/#{node['nagios']['nrpe']['file']}"

default['nagios']['ncpa']['file'] = 'check_ncpa.tar.gz'
default['nagios']['ncpa']['url'] = "https://assets.nagios.com/downloads/ncpa/#{node['nagios']['ncpa']['file']}"

default['nagios']['packages']['core'] = %w(autoconf gcc libc6 libgd-dev mailutils make php unzip)
default['nagios']['packages']['plugins'] = %w(autoconf bc build-essential dc gawk gcc gettext libc6 libmcrypt-dev libnet-snmp-perl libssl-dev make snmp wget)
