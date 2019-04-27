import os
import docker
import yaml

CLOUDBUILD_CONFIG = 'cloudbuild-vm.yaml'
PACKER_DIR = 'vm/packer/templates'


class GenerateTriggerConfig():

  def __init__(self, cookbook):
    self._cookbook = cookbook

  def get_packer_run_list(self):
    return []

  def should_include_test(self):
    return True

  def generate_config(self):
    trigger = {
        'description': 'Trigger for VM %s' % self._cookbook,
        'filename': CLOUDBUILD_CONFIG,
        'github': {
            'name': 'click-to-deploy',
            'owner': 'GoogleCloudPlatform',
            'pullRequest': {
                'branch': '.*',
                'commentControl': 'COMMENTS_ENABLED'
            }
        },
        'includedFiles': [
            'vm/packer/templates/%s/**' % self._cookbook, CLOUDBUILD_CONFIG
        ],
        'substitutions': {
            '_LOGS_BUCKET': 'XXX',
            '_SERVICE_ACCOUNT_JSON_GCS': 'gs://XXX/XXX.json',
            '_SOLUTION_NAME': '%s' % self._cookbook
        }
    }

    if self.should_include_test():
      trigger['includedFiles'].append(
          os.path.join('vm/tests/solutions/spec', self._cookbook, '**'))

    client = docker.from_env()
    deps = client.containers.run(
        image='chef/chefdk',
        working_dir='/chef',
        entrypoint='knife',
        command=[
            'deps', '--config-option', 'cookbook_path=/chef/cookbooks',
            os.path.join('/cookbooks', self._cookbook)
        ],
        volumes={
            os.path.join(os.getcwd(), 'vm/chef'): {
                'bind': '/chef',
                'mode': 'ro'
            }
        },
        auto_remove=True)

    for dep in deps.splitlines():
      trigger['includedFiles'].append(os.path.join('vm/chef', dep, '**'))

    return trigger


def main():
  triggers = []

  # listdir = [f for f in os.listdir(PACKER_DIR)
  #            if os.path.isdir(os.path.join(PACKER_DIR, f))]
  # listdir.sort()

  listdir = ['wordpress-ha']

  for solution in listdir:
    triggers.append(GenerateTriggerConfig(solution).generate_config())

  print yaml.dump_all(triggers, default_flow_style=False)


if __name__ == '__main__':
  main()
