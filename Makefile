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

python-test:
	@python --version
	@python -m unittest discover -s scripts -p "*_test.py"

vm-lint:
	@foodcritic --version
	@foodcritic --cookbook-path=vm/chef/cookbooks --rule-file=vm/chef/.foodcritic --epic-fai=any

k8s-cloudbuild-generator:
	@python scripts/cloudbuild_k8s_generator.py

k8s-cloudbuild-verify:
	@python scripts/cloudbuild_k8s_generator.py --verify_only
