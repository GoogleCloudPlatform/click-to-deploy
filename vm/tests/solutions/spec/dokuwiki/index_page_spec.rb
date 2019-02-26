# Copyright 2018 Google LLC
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

require 'spec_helper'

describe command('curl -L http://localhost/') do
  its(:stdout) { should match /<meta name="generator" content="DokuWiki"\/>/ }
  its(:stdout) { should match /<a href="https:\/\/dokuwiki.org\/" title="Driven by DokuWiki" >/ }
  its(:stdout) { should match /<p>\nYou are currently not logged in! Enter your authentication credentials below to log in. You need to have cookies enabled to log in.\n<\/p>/ }
  its(:exit_status) { should eq 0 }
end
