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

default['postgresql']['packages'] = ['postgresql', 'postgresql-client']
default['postgresql']['repository_url'] = 'http://apt.postgresql.org/pub/repos/apt/'
default['postgresql']['key'] = 'https://www.postgresql.org/media/keys/ACCC4CF8.asc'

default['postgresql']['standalone']['distribution'] = 'stretch'

default['postgresql']['cluster']['packages'] = ['postgresql-plperl-13', 'postgresql-client']
default['postgresql']['cluster']['distribution'] = 'buster'
