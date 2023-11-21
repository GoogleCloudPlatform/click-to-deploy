# Copyright 2023 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,``
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

default['dolibarr']['version'] = '18.0.2'
default['dolibarr']['sha256'] = 'b3306562480a3194822f4f7c3c9909a147a5e1b09a7404abe75a0fa884fd00f6'

default['dolibarr']['linux']['user'] = 'www-data'
default['dolibarr']['db']['name'] = 'dolibarr'

default['php81']['distribution'] = 'bullseye'
