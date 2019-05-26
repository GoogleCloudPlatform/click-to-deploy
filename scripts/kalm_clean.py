#!/usr/bin/env python
#
# Copyright 2018 Google LLC
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

import os
from ruamel.yaml import YAML

yaml = YAML()
yaml.default_flow_style = False

SCHEMA_CONFIG = 'schema.yaml'


def main():
  listdir = [
      f for f in os.listdir('k8s') if os.path.isdir(os.path.join('k8s', f))
  ]

  for solution in listdir:
    schema_file = os.path.join('k8s', solution, SCHEMA_CONFIG)

    with open(schema_file) as f:
      schema = yaml.load(f)

    x_google_marketplace = schema.get('x-google-marketplace', {})

    if 'publishedVersionMetadata' in x_google_marketplace:
      metadata = x_google_marketplace['publishedVersionMetadata']
      metadata['releaseNote'] = 'A regular update.'
      metadata['releaseTypes'] = ['Feature']
      metadata['recommended'] = False

    with open(schema_file, 'w') as f:
      yaml.dump(schema, f)


if __name__ == '__main__':
  main()
