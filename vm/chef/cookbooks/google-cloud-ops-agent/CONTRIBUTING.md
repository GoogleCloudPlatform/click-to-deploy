# Contributing to this Chef Cookbook

## Submitting Issues

Not every contribution comes in the form of code. Submitting, confirming, and triaging issues is an important task for any project. We use GitHub to track all project issues.

If you are familiar with Chef and know the component that is causing you a problem, you can file an issue in the corresponding GitHub project.

## Contribution Process

We have a 3 step process for contributions:

1. Commit changes to a git branch, likely on your own fork
2. Create a GitHub Pull Request for your change, following the instructions in these documents:
- [GitHub Documentation Collaborative Development](https://docs.github.com/en/github/collaborating-with-pull-requests/getting-started/about-collaborative-development-models)
- [GitFlow Document](https://guides.github.com/introduction/flow/)
3. Perform a [Code Review](#code-review-process) with the project maintainers on the pull request.

### Pull Request Requirements

1. **Tests:** To ensure high quality code and protect against future regressions, we require all the code to have at least integration test coverage. We use [CINC Auditor](https://cinc.sh/start/auditor/) for integration testing.
2. **Green CI Tests:** We use [GitHub Actions](https://github.com/features/actions) to test all pull requests. We require these test runs to succeed on every pull request before being merged.

### Code Review Process

Code review takes place in GitHub pull requests. See [this article](https://help.github.com/articles/about-pull-requests/) if you're not familiar with GitHub Pull Requests.

Once you open a pull request, project maintainers will review your code and respond to your pull request with any feedback they might have. The process at this point is as follows:

1. At least one member of the owners, approvers, or reviewers groups must approve your PR.
2. Your change will be merged into the project's `master` branch
3. Changes in master will appear in published versions as part of our standard release cycle

## Editing The Cookbook

This cookbook is written in Ruby. It follows the standard development model for a [Chef Cookbook](https://docs.chef.io/cookbooks/)

### Adding a Test Case

All test cases are written for [CINC Auditor](https://cinc.sh/start/auditor/), which is the open source version of [Chef InSpec](https://docs.chef.io/inspec/)

### Running Tests Locally with Vagrant

The Vagrant driver for [Test Kitchen](https://kitchen.ci/docs/getting-started/introduction/) is used for local testing of Linux systems. Due to the need for Google specific image set up on Windows systems, the tests have to be run in GCE.
Any system image available on [Vagrant's Bento Project](https://app.vagrantup.com/bento/) can theoritically be used, though we suggest an image for a supported OS.
Our Test Kitchen is from [CINC Workstation](https://cinc.sh/start/workstation/)
Required environment variables are documented in kitchen_local.yml and must be set in order for Test Kitchen to correctly run the tests.
Once your environment is set up correctly, you can run `kitchen test` to run the full suite of tests and process end to end
Otherwise you can do individual test kitchen steps, such as create or converge,  as described in their documentation.
**NOTE**: The agents are intended to be run in GCP, but this testing with Vagrant can be used to smoke test changes.

#### Environment Variable Examples for Running Tests in Vagrant

This example will rin ops-agent v2.0.1 tests for CentOS 8.3
```
export CHEF_PLATFORM=centos-8.3
export AGENT_TYPE=ops-agent
export VERSION=2.0.1
export CHEF_TEST_DIR=test/integration/linux/${AGENT_TYPE}/${VERSION}
export STATE="present"
export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
```

This example will run ops-agent v2.0.1 tests for Oracle Linux 8.3
```
export CHEF_PLATFORM=oracle-8.3
export AGENT_TYPE=ops-agent
export VERSION=2.0.1
export CHEF_TEST_DIR=test/integration/linux/${AGENT_TYPE}/${VERSION}
export STATE="present"
export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
```

### Running Tests in GCE

Test Kitchen's GCE driver is used to run tests in Google Compute Image. This is what our CI uses to spin up tests against a large number of operating systems to validate that everything is working as intended.
As with the local tests described above, a group of environment variables documented in kitchen.yml need to be set to correctly run the test cases.
Again, once the environment is set up correctly simply run `kitchen test` for an end to end testing experience.

#### Environment Variable Examples for Running Tests in GCE

This example will run ops-agent v2.0.1 tests for SuSE Enterprise Linux Server 15
```
export CHEF_GCP_PROJECT=gce_chef_testing
export CHEF_GCP_SA_EMAIL=someguy@testemail.org
export CHEF_SSH_USER=someuser
export CHEF_SSH_KEY=/path/to/chef-ci/id_rsa
export GOOGLE_APPLICATION_CREDENTIALS=/path/to/gce_chef_testing.json
export CHEF_PLATFORM=suse-15
export CHEF_IMAGE_PROJECT="suse-cloud"
export CHEF_IMAGE_FAMILY="sles-15"
export CHEF_IMAGE_APPLICATION="suse"
export CHEF_IMAGE_RELEASE="a"
export CHEF_IMAGE_VERSION="15"
export AGENT_TYPE=ops-agent
export VERSION=2.0.1
export CHEF_TEST_DIR=test/integration/linux/${AGENT_TYPE}/${VERSION}
export STATE="present"
export CHEF_CLIENT_URL=https://omnitruck.cinc.sh/install.sh
```

Further examples can be found in .github/scripts/configure_kitchen.sh from the cookbook directory, which is used for CI in the repo.
