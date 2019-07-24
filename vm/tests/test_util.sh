#!/bin/bash
#
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
#
# This file is the first file which has to be included at the beginning of a test script.
# Example:
#
# source "$(dirname "${0}")/test_util.sh"

set -eu

function start_test_msg() { echo ">> Test: ${1} ..."; }
function success() { echo "> PASSED"; }
function failure() { echo "> FAILED" && exit 1; }
function failure_msg() { echo "> FAILED: ${1}" && exit 1; }
function warning() { echo "> WARNING" && exit 2; }
function warning_msg() { echo "> WARNING: ${1}" && exit 2; }
