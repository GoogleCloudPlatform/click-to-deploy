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

default['grafana']['repo']['uri'] = 'https://packages.grafana.com/oss/deb'
default['grafana']['repo']['components'] = ['main']
default['grafana']['repo']['distribution'] = 'stable'
default['grafana']['repo']['key'] = 'https://packages.grafana.com/gpg.key'
default['grafana']['version'] = '9.3.2'
default['grafana']['apt_version'] = "#{default['grafana']['version']}.*"
