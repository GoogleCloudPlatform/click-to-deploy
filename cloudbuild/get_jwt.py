#!/usr/bin/env python2
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

import datetime
import time
import jwt
from argparse import ArgumentParser

def main():
  parser = ArgumentParser(description= "Generate the jwt token from a secret file")
  parser.add_argument('--secret',
                      help='Path to the secret file.')
  parser.add_argument('--issuer',
                      help='In case of github app, it is the application number.')
  args = parser.parse_args()

  now = datetime.datetime.now()
  message = {
      'iss': args.issuer,
      'iat': int(time.mktime(now.timetuple())),
      'exp': int(time.mktime((now + datetime.timedelta(minutes=10)).timetuple())),
  }

  with open(args.secret, 'rb') as fh:
      signing_key = fh.read()

  compact_jws = jwt.encode(message, signing_key, 'RS256')

  print(compact_jws)

if __name__ == "__main__":
  main()
