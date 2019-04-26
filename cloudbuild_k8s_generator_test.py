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
