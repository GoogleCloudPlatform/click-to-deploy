
# Copyright 2022 Google LLC
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

<<<<<<< HEAD
default['resourcespace']['version'] = '10.1'
=======
default['resourcespace']['version'] = '9.8'
>>>>>>> parent of 1ba3f97b (updated)
default['resourcespace']['db']['name'] = 'resourcespace'

default['resourcespace']['packages'] = ['antiword',
                                        'cron',
                                        'imagemagick',
                                        'inkscape',
                                        'libimage-exiftool-perl',
                                        'ffmpeg',
                                        'ghostscript',
                                        'subversion',
                                        'xpdf',
                                        ]
default['php81']['distribution'] = 'bullseye'
