#!/usr/bin/env python3
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

from argparse import ArgumentParser
import os
import yaml
import subprocess
import json
import copy

_PROG_HELP = """
Scans the deployed Cloud Build triggers for k8s aps and compare them to the respective yaml configs in the repo.
"""

copyright_header="""# Copyright 2020 Google LLC
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

"""

parser = ArgumentParser(description=_PROG_HELP)
parser.add_argument('--project', help='The GCP project', required=True)
parser.add_argument('--triggers_dir', help='The directory that contains the triggers for all solutions', required=True)
parser.add_argument('--solutions_dir', help='The directory that contains all solutions', required=True)
parser.add_argument('--update_trigger_id', help='Automatically updates the deployed trigger ids in the trigger files', action='store_true') 
args = parser.parse_args()

errors = []

def equal_obj(a, b):
  return ordered(a) == ordered(b)


def ordered(obj):
  if isinstance(obj, dict):
    return sorted((k, ordered(v)) for k, v in obj.items())
  if isinstance(obj, list):
    return sorted(ordered(x) for x in obj)
  else:
    return obj


def handle_trigger_id_mismatch(solution_name, trigger_path, trigger):
  if args.update_trigger_id:
    with open(trigger_path, "w") as stream:
      stream.write(copyright_header)
      trigger = copy.deepcopy(trigger)
      del trigger['createTime']
      stream.write(yaml.dump(trigger))
  else:
    errors.append("Local trigger id needs to be updated: {}, {}".format(solution_name, trigger['id']))


def main():
  process = subprocess.check_output(['gcloud', 'alpha', 'builds', 'triggers', 'list', '--project=' + args.project, '--format=json'])
  triggers = json.loads(process)

  trigger_by_solution = {}

  for t in triggers:
    # print(yaml.dump(t))
    try:
      if 'includedFiles' not in t:
        continue
      
      if not any(map(lambda x: 'k8s' in x, t['includedFiles'])):
        continue
      
      if not 'substitutions' in t:
        continue
      
      if not '_SOLUTION_NAME' in t['substitutions']:
        continue

      trigger_by_solution[t['substitutions']['_SOLUTION_NAME']] = t
    except Exception as ex:
      errors.append("Failed to process trigger.\n{}\n{}".format(yaml.dump(t), str(ex)))

  # Discover the solutions in the solutions directory. 
  for solution_name in os.listdir(args.solutions_dir):
    # All files are ignored.
    if not os.path.isdir(os.path.join(args.solutions_dir, solution_name)):
      continue

    trigger_path = os.path.join(args.triggers_dir, solution_name + ".yaml")
    
    if not os.path.exists(trigger_path):
      errors.append("Trigger file does not exist: {}".format(trigger_path))
      continue

    if solution_name in trigger_by_solution:
      trigger = trigger_by_solution[solution_name]
      
      with open(trigger_path, "r") as stream:
        local_trigger = yaml.load(stream.read(), Loader=yaml.Loader)
      if 'id' in local_trigger:
        if local_trigger['id'] != trigger['id']:
          local_trigger['id'] = trigger['id']
          if not equal_obj(local_trigger, trigger):
            errors.append("Local trigger does not match deployed trigger: {}".format(solution_name))
          else:
            handle_trigger_id_mismatch(solution_name, trigger_path, trigger)
      else:
        handle_trigger_id_mismatch(solution_name, trigger_path, trigger)
    else:
      errors.append("Missing trigger: {}".format(solution_name))
    
  for e in errors:
    print(e)

if __name__ == "__main__":
  main()
