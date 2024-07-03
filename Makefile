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

# TODO(wgrzelak): Invoke targets into the container.

.DEFAULT_GOAL := help

.PHONY: help
help: ## Shows help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.PHONY: python-test
python-test: ## Runs tests for Python scripts
	@python --version
	@python -m unittest discover -s scripts -p "*_test.py"

.PHONY: vm-lint
vm-lint: ## Runs lint for Chef cookbooks
	@docker pull chef/chefworkstation
	# cookstyle print version
	@docker run --rm --entrypoint cookstyle -v $(PWD)/vm/chef:/chef:ro chef/chefworkstation --version
	# cookstyle on cookbooks
	@docker run --rm --entrypoint cookstyle -v $(PWD)/vm/chef:/chef:ro chef/chefworkstation /chef/cookbooks
	# cookstyle on tests
	@docker run --rm --entrypoint cookstyle -v $(PWD)/vm/tests:/tests:ro chef/chefworkstation /tests/solutions

.PHONY: vm-generate-triggers
vm-generate-triggers: ## Generates and displays GCB triggers for VM
	@python scripts/triggers_vm_generator.py
