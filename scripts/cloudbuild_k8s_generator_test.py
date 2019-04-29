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

import unittest
import tempfile
import cloudbuild_k8s_generator


class CloudBuildK8sGeneratorTest(unittest.TestCase):

  def test_verify_cloudbuild(self):
    cloudbuild_config = """
    steps:
      - id: Pull Dev Image
        name: gcr.io/cloud-builders/docker
        dir: k8s
    """
    with tempfile.NamedTemporaryFile(delete=True) as f:
      f.write(cloudbuild_config)
      f.flush()
      self.assertTrue(
          cloudbuild_k8s_generator.verify_cloudbuild(f.name, cloudbuild_config))
      self.assertFalse(cloudbuild_k8s_generator.verify_cloudbuild(f.name, None))
      self.assertFalse(
          cloudbuild_k8s_generator.verify_cloudbuild('/incorrect_path', None))


if __name__ == '__main__':
  unittest.main()
