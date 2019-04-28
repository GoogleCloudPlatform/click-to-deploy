import os
import docker
import yaml
import json

CLOUDBUILD_CONFIG = 'cloudbuild-vm.yaml'
PACKER_DIR = 'vm/packer/templates'
TESTS_DIR = 'vm/tests/solutions/spec'


class GenerateTriggerConfig():

  def __init__(self, solution):
    self._solution = solution

  def get_packer_run_list(self):
    with open(os.path.join(PACKER_DIR, self._solution, 'packer.in.json')) as json_file:
      data = json.load(json_file)
      run_list = data['chef']['run_list']
    return [cookbook.split('::')[0] for cookbook in run_list]

  def should_include_test(self):
    return True

  def get_cookbook_deps(self, cookbook):
    client = docker.from_env()
    deps = client.containers.run(
        image='chef/chefdk',
        working_dir='/chef',
        entrypoint='knife',
        command=[
            'deps', '--config-option', 'cookbook_path=/chef/cookbooks',
            os.path.join('/cookbooks', cookbook)
        ],
        volumes={
            os.path.join(os.getcwd(), 'vm/chef'): {
                'bind': '/chef',
                'mode': 'ro'
            }
        },
        auto_remove=True)
    return deps.splitlines()

  def get_included_files(self):
    included_files = [
        os.path.join(PACKER_DIR, self._solution, '**'),
        CLOUDBUILD_CONFIG
    ]

    if self.should_include_test():
      included_files.append(
          os.path.join(TESTS_DIR, self._solution, '**'))

    for cookbook in self.get_packer_run_list():
      for dep in self.get_cookbook_deps(cookbook=cookbook):
        included_files.append(os.path.join('vm/chef', dep, '**'))

    included_files = self.remove_duplicates(included_files)
    included_files.sort()
    return included_files

  def remove_duplicates(self, included_files):
    return list(dict.fromkeys(included_files))

  def generate_config(self, included_files):
    trigger = {
        'description': 'Trigger for VM %s' % self._solution,
        'filename': CLOUDBUILD_CONFIG,
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


def main():
  triggers = []

  # listdir = [f for f in os.listdir(PACKER_DIR)
  #            if os.path.isdir(os.path.join(PACKER_DIR, f))]
  # listdir.sort()

  listdir = ['wordpress-ha']

  for solution in listdir:
    trigger = GenerateTriggerConfig(solution)
    included_files = trigger.get_included_files()
    triggers.append(trigger.generate_config(included_files))

  print yaml.dump_all(triggers, default_flow_style=False)


if __name__ == '__main__':
  main()
