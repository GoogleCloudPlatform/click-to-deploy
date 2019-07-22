#!/usr/bin/env python
#
# Copyright 2019 Google LLC
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

import argparse
import json
import os
import subprocess
import yaml

CLOUDBUILD_CONFIG_FILE = 'cloudbuild-vm.yaml'
COOKBOOKS_DIR = 'vm/chef/cookbooks'
PACKER_DIR = 'vm/packer/templates'
TESTS_DIR = 'vm/tests/solutions/spec'


class VmTriggerConfig(object):
  """Generates GCB trigger for VM solution."""

  def __init__(self, solution, knife_binary):
    self._solution = solution
    self._knife_binary = knife_binary

  @property
  def packer_run_list(self):
    """Returns Chef's run_list from Packer's template."""
    with open(os.path.join(self.packer_dir, 'packer.in.json')) as json_file:
      data = json.load(json_file)
      run_list = data['chef']['run_list']
    return [cookbook.split('::', 1)[0] for cookbook in run_list]

  @property
  def should_include_test(self):
    """Returns whether solution has tests."""
    return True

  @property
  def packer_dir(self):
    """Returns path to the Packer's template directory."""
    return os.path.join(PACKER_DIR, self._solution)

  @property
  def tests_dir(self):
    """Returns path to the tests directory."""
    return os.path.join(TESTS_DIR, self._solution)

  @property
  def included_files(self):
    """Returns list of included files."""
    included_files = [
        os.path.join(self.packer_dir, '**'), CLOUDBUILD_CONFIG_FILE
    ]

    if self.should_include_test:
      included_files.append(os.path.join(self.tests_dir, '**'))

    for cookbook in self.packer_run_list:
      for dep in get_cookbook_deps(
          cookbook=cookbook, knife_binary=self._knife_binary):
        included_files.append(os.path.join('vm/chef', dep, '**'))

    included_files = self.remove_duplicates(included_files)
    return included_files

  def remove_duplicates(self, included_files):
    """Removes duplicates from a List."""
    final_list = []
    for num in included_files:
      if num not in final_list:
        final_list.append(num)
    return final_list

  def generate_config(self):
    """Generates GCB trigger config."""
    included_files = self.included_files
    included_files.sort()
    trigger = {
        'description': 'Trigger for VM %s' % self._solution,
        'filename': CLOUDBUILD_CONFIG_FILE,
        'github': {
            'name': 'click-to-deploy',
            'owner': 'GoogleCloudPlatform',
            'pullRequest': {
                'branch': '.*',
                'commentControl': 'COMMENTS_ENABLED'
            }
        },
        'includedFiles': included_files,
        'substitutions': {
            '_SOLUTION_NAME': self._solution
        }
    }
    return trigger


def invoke_shell(args):
  """Invokes a shell command."""
  child = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  output, _ = child.communicate()
  exit_code = child.returncode
  return output, exit_code


def get_cookbook_deps(cookbook, knife_binary):
  """Returns cookbooks dependencies."""
  command = [
      knife_binary, 'deps', '--config-option',
      'cookbook_path=%s' % COOKBOOKS_DIR,
      os.path.join(COOKBOOKS_DIR, cookbook)
  ]
  deps, exit_code = invoke_shell(command)
  assert exit_code == 0
  return deps.splitlines()


def get_solutions_list():
  """Returns list of solutions."""
  listdir = [
      f for f in os.listdir(PACKER_DIR)
      if os.path.isdir(os.path.join(PACKER_DIR, f))
  ]
  listdir.sort()
  return listdir


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument(
      '--knife_binary', type=str, default='knife', help='knife-solo binary')
  args = parser.parse_args()

  listdir = get_solutions_list()
  triggers = []

  for solution in listdir:
    trigger = VmTriggerConfig(solution=solution, knife_binary=args.knife_binary)
    triggers.append(trigger.generate_config())

  print(yaml.dump_all(triggers, default_flow_style=False))


if __name__ == '__main__':
  os.sys.exit(main())
