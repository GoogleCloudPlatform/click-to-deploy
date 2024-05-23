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

default['valkey']['version'] = '7.2.5'

default['valkey']['download_url'] =
  "https://github.com/valkey-io/valkey/archive/refs/tags/#{default['valkey']['version']}.tar.gz"

default['valkey']['packages'] = [
  'ca-certificates',
  'wget',
  'dpkg-dev',
  'gcc',
  'libc6-dev',
  'libssl-dev',
  'make',
]
