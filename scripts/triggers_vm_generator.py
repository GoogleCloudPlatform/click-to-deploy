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
import logging
import multiprocessing.pool
import os
import subprocess
import sys
import yaml

CLOUDBUILD_CONFIG_FILE = 'cloudbuild-vm.yaml'
COOKBOOKS_DIR = 'vm/chef/cookbooks'
PACKER_DIR = 'vm/packer/templates'
TESTS_DIR = 'vm/tests/solutions/spec'

_COOKBOOKS = {}


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
      included_files.extend([
          os.path.join(COOKBOOKS_DIR, dep, '**') for dep in get_cookbook_deps(
              cookbook=cookbook, knife_binary=self._knife_binary)
      ])

    included_files = self._remove_duplicates(included_files)
    return included_files

  def _remove_duplicates(self, included_files):
    """Removes duplicates from a List."""
    final_list = []
    for num in included_files:
      if num not in final_list:
        final_list.append(num)
    return final_list

  def generate_config(self, included_files):
    """Generates GCB trigger config."""
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


class CreateThreadPoolAndWait(object):
  """Creates thread pool and wait for all jobs to finish.

  For example:

  with CreateThreadPoolAndWait() as pool:
    result1=pool.apply_async(func1)
    result2=pool.apply_async(func2)
  """

  def __init__(self):
    self._pool = multiprocessing.pool.ThreadPool()

  def __enter__(self):
    return self._pool

  def __exit__(self, exc_type, exc_val, exc_tb):
    self._pool.close()
    self._pool.join()


def invoke_shell(args):
  """Invokes a shell command."""
  logging.debug('Executing command: %s', args)
  child = subprocess.Popen(args, stdout=subprocess.PIPE, stderr=subprocess.PIPE)
  output, _ = child.communicate()
  exit_code = child.returncode
  return output.decode('utf-8'), exit_code


def get_cookbook_deps(cookbook, knife_binary):
  """Returns cookbooks dependencies."""
  if cookbook in _COOKBOOKS:
    # do not check cookbook twice
    return _COOKBOOKS[cookbook]

  command = [
      knife_binary, 'deps', '--config-option',
      'cookbook_path=%s' % COOKBOOKS_DIR,
      os.path.join('/cookbooks', cookbook)
  ]
  deps, exit_code = invoke_shell(command)
  assert exit_code == 0, exit_code
  deps = [dep.replace('/cookbooks/', '') for dep in deps.splitlines()]

  _COOKBOOKS[cookbook] = deps
  return deps


def get_solutions_list():
  """Returns list of solutions."""
  listdir = [
      f for f in os.listdir(PACKER_DIR)
      if os.path.isdir(os.path.join(PACKER_DIR, f))
  ]
  listdir.sort()
  return listdir


def generate_config(solution, knife_binary):
  trigger = VmTriggerConfig(solution=solution, knife_binary=knife_binary)
  included_files = trigger.included_files
  return trigger.generate_config(included_files)


def main():
  parser = argparse.ArgumentParser()
  parser.add_argument(
      '--knife_binary', type=str, default='knife', help='knife-solo binary')
  args = parser.parse_args()

  listdir = get_solutions_list()

  with CreateThreadPoolAndWait() as pool:
    triggers_results = [
        pool.apply_async(generate_config, (solution, args.knife_binary))
        for solution in listdir
    ]

  triggers = [result.get() for result in triggers_results]

  print(yaml.dump_all(triggers, default_flow_style=False))


if __name__ == '__main__':
  logging.basicConfig(stream=sys.stderr, level=logging.DEBUG)
  os.sys.exit(main())
