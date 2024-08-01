# Copyright 2024 Google LLC
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

default['pimcore']['version'] = '11.1.4'
default['pimcore']['db']['name'] = 'pimcore'
default['pimcore']['packages'] = [
  'unzip',
  'cron',
  'autoconf',
  'automake',
  'libtool',
  'nasm',
  'make',
  'pkg-config',
  'libz-dev',
  'build-essential',
  'openssl',
  'g++',
  'zlib1g-dev',
  'libicu-dev',
  'libbz2-dev',
  'libc-client-dev',
  'libkrb5-dev',
  'libxml2-dev',
  'libxslt1.1',
  'libxslt1-dev',
  'locales',
  'locales-all',
  'ffmpeg',
  'html2text',
  'ghostscript',
  'libreoffice',
  'pngcrush',
  'jpegoptim',
  'exiftool',
  'poppler-utils',
  'wget',
  'libx11-dev',
  'python3-pip',
  'opencv-data',
  'webp',
  'graphviz',
  'cmake',
  'ninja-build',
  'liblcms2-dev',
  'liblqr-1-0-dev',
  'libopenjp2-7-dev',
  'libtiff-dev',
  'libfontconfig1-dev',
  'libfftw3-dev',
  'libltdl-dev',
  'liblzma-dev',
  'libopenexr-dev',
  'libwmf-dev',
  'libdjvulibre-dev',
  'libpango1.0-dev',
  'libxext-dev',
  'libxt-dev',
  'librsvg2-dev',
  'libzip-dev',
  'libpng-dev',
  'libfreetype6-dev',
  'libjpeg-dev',
  'libxpm-dev',
  'libwebp-dev',
  'libjpeg62-turbo-dev',
  'libonig-dev',
  'gimp',
]

default['php81']['distribution'] = 'bullseye'
