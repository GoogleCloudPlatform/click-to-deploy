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

default['liferay']['version'] = '7.4.3.55-ga55'
# SHA1 value check for liferay SOURCE, the cookbook download it from
# https://github.com/liferay/liferay-portal/archive/refs/tags/<version>.tar.gz
default['liferay']['sha1']['source'] = 'c65f7a3882ea03dea8b85dac09ca571e72a9d909'
# SHA1 value check for liferay bundle, the cookbook download it from
# https://github.com/liferay/liferay-portal/releases/download/<version>/liferay-ce-portal-tomcat-<version>-<date>.tar.gz
default['liferay']['sha1']['bundle'] = 'ad592944a7ce33b479b9c2f1fb7ff08c51df1b64'
default['liferay']['packages'] = ['jq', 'zip']

default['liferay']['home'] = '/opt/liferay'
default['liferay']['java']['home'] = '/usr/lib/jvm/java-11-openjdk-amd64/'

default['liferay']['linux']['user'] = 'liferay'
default['liferay']['db']['name'] = 'liferay'
