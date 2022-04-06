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

default['kong']['version'] = '2.8.0'
default['kong']['sha256'] = '8f8b1cfb6d72898d558eed2823628cf90bec8aab9bf59883b498f2159308772b'
default['kong']['db']['name'] = 'kong'
default['kong']['packages'] = ['zlib1g-dev', 'boxes']
