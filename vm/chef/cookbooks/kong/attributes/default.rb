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

default['kong']['version'] = '3.0.2'
default['kong']['sha256'] = 'f1044c40e758583e78015ae7eeaa1f8267cd03e51215de66c175983017dec7b8'
default['kong']['db']['name'] = 'kong'
default['kong']['packages'] = ['zlib1g-dev', 'boxes']
