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

import time
import triggers_vm_generator
import unittest


class CreateThreadPoolAndWaitTest(unittest.TestCase):

  def test_close(self):
    with self.assertRaises(AssertionError):
      with triggers_vm_generator.CreateThreadPoolAndWait() as pool:
        pass
      pool.apply_async(lambda: True)

  def test_join(self):
    with triggers_vm_generator.CreateThreadPoolAndWait() as pool:
      # task takes 3 sec to complete
      result = pool.apply_async(time.sleep, (3,))
    self.assertTrue(result.successful())


class TriggersVmGeneratorTest(unittest.TestCase):

  def test_invoke_shell(self):
    self.assertEqual(('1\n', 0),
                     triggers_vm_generator.invoke_shell(['echo', '1']))
    self.assertEqual(
        ('', 0),
        triggers_vm_generator.invoke_shell(['/bin/bash', '-c', 'exit 0']))
    self.assertEqual(
        ('', 1),
        triggers_vm_generator.invoke_shell(['/bin/bash', '-c', 'exit 1']))
    self.assertEqual(
        ('', 2),
        triggers_vm_generator.invoke_shell(['/bin/bash', '-c', 'exit 2']))


class VmTriggerConfigTest(unittest.TestCase):

  def setUp(self):
    super(VmTriggerConfigTest, self).setUp()
    self.trigger = triggers_vm_generator.VmTriggerConfig(
        solution='wordpress', knife_binary='/bin/bash')

  def test_packer_run_list(self):
    # TODO(wgrzelak): Implement unittest.
    pass

  def test_should_include_test(self):
    self.assertTrue(self.trigger.should_include_test)

  def test_packer_dir(self):
    self.assertEqual('vm/packer/templates/wordpress', self.trigger.packer_dir)

  def test_tests_dirr(self):
    self.assertEqual('vm/tests/solutions/spec/wordpress',
                     self.trigger.tests_dir)

  def test_included_files(self):
    # TODO(wgrzelak): Implement unittest.
    pass

  def test_remove_duplicates(self):
    self.assertEqual(['a', 'b'],
                     self.trigger._remove_duplicates(['a', 'a', 'b']))

  def test_generate_config(self):
    # TODO(wgrzelak): Implement unittest.
    pass


if __name__ == '__main__':
  unittest.main()
