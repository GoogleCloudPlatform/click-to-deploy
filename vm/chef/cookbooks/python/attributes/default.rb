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

default['python']['minor'] = '3.10'
default['python']['version'] = '3.10.0'
default['python']['deps_packages'] = [
  'build-essential',
  'zlib1g-dev',
  'libncurses5-dev',
  'libgdbm-dev',
  'libnss3-dev',
  'libssl-dev',
  'libreadline-dev',
  'libffi-dev',
  'libsqlite3-dev',
  'wget',
  'libbz2-dev',
]
