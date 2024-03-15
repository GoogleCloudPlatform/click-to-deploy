# Copyright 2024 Google LLC
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

default['jenkins']['packages'] = %w(jenkins git subversion)

default['jenkins']['repo']['uri'] = 'http://pkg.jenkins.io/debian-stable'
default['jenkins']['repo']['components'] = ['binary/']
default['jenkins']['repo']['keyserver'] = 'https://pkg.jenkins.io/debian/jenkins.io.key'

default['jenkins']['ivy']['version'] = '2.5.2'
default['jenkins']['ivy']['download_url'] = "https://dlcdn.apache.org/ant/ivy/#{default['jenkins']['ivy']['version']}/apache-ivy-#{default['jenkins']['ivy']['version']}-bin.tar.gz"

default['jenkins']['xstream']['version'] = '1.4.20'
default['jenkins']['xstream']['download_url'] = "https://repo1.maven.org/maven2/com/thoughtworks/xstream/xstream-distribution/#{default['jenkins']['xstream']['version']}/xstream-distribution-#{default['jenkins']['xstream']['version']}-bin.zip"
