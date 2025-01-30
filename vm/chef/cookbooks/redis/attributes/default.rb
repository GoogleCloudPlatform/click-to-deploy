# Copyright 2023 Google LLC
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

default['redis']['version'] = '7.2.6'

default['redis']['download_url'] =
  "http://download.redis.io/releases/redis-#{default['redis']['version']}.tar.gz"

default['redis']['packages']['temp_dependencies'] = ['dpkg-dev', 'gcc', 'make']
default['redis']['packages']['dependencies'] = ['libjemalloc2']

default['redis']['packages']['all_dependencies'] =
  default['redis']['packages']['temp_dependencies'] +
  default['redis']['packages']['dependencies']
