# Copyright 2021 Google LLC
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

default['liferay']['version'] = '7.4.3.10-ga10'
# SHA1 value check for liferay SOURCE, the cookbook download it from
# https://github.com/liferay/liferay-portal/archive/refs/tags/<version>.tar.gz
default['liferay']['sha1']['source'] = '280929de4c00f15412e831a5b1b8d9969ed57afd'
# SHA1 value check for liferay bundle, the cookbook download it from
# https://github.com/liferay/liferay-portal/releases/download/<version>/liferay-ce-portal-tomcat-<version>-<date>.tar.gz
default['liferay']['sha1']['bundle'] = 'a6c3d508805ff221f1d76ffac73dacafcea7303b'
default['liferay']['packages'] = ['jq', 'zip']

default['liferay']['home'] = '/opt/liferay'
default['liferay']['java']['home'] = '/usr/lib/jvm/java-8-openjdk-amd64/'

default['liferay']['linux']['user'] = 'liferay'
default['liferay']['db']['name'] = 'liferay'
