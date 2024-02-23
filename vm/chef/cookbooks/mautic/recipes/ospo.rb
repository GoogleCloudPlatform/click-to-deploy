# Copyright 2023 Google LLC
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

ospo_download 'Licenses and Source-code' do
  repos <<-EOF
https://github.com/mautic/mautic.git
https://github.com/mautic/Transifex-API.git
https://github.com/ckeditor/ckeditor4.git
https://github.com/furf/jquery-ui-touch-punch.git
https://github.com/jsplumb/jsplumb.git
EOF
  licenses <<-EOF
Mautic;https://github.com/mautic/mautic/blob/5.x/LICENSE.txt
PHP;https://github.com/php/php-src/blob/master/LICENSE
Zend_Engine;https://github.com/php/php-src/blob/master/Zend/LICENSE
Apache_httpd;https://github.com/apache/httpd/blob/trunk/LICENSE
MySQL;https://github.com/mysql/mysql-server/blob/8.0/LICENSE
Duktape;https://github.com/mysql/mysql-server/blob/8.0/extra/duktape/duktape-2.7.0/LICENSE.txt
googletest;https://github.com/google/googletest/blob/main/LICENSE
libcbor;https://github.com/mysql/mysql-server/blob/8.0/extra/libcbor/LICENSE.md
libedit;https://github.com/mysql/mysql-server/blob/8.0/extra/libedit/libedit-20210910-3.1/COPYING
libevent;https://github.com/mysql/mysql-server/blob/8.0/extra/libevent/libevent-2.1.11-stable/LICENSE
libfido;https://github.com/mysql/mysql-server/blob/8.0/extra/libfido2/libfido2-1.8.0/LICENSE
lz4;https://github.com/mysql/mysql-server/blob/8.0/extra/lz4/lz4-1.9.4/LICENSE
protobuf;https://github.com/mysql/mysql-server/blob/8.0/extra/protobuf/protobuf-3.19.4/LICENSE
rapidjson;https://github.com/mysql/mysql-server/blob/8.0/extra/rapidjson/license.txt
RobinhoodHashing;https://github.com/mysql/mysql-server/blob/8.0/extra/robin-hood-hashing/LICENSE
zlib;https://github.com/mysql/mysql-server/blob/8.0/extra/zlib/zlib-1.2.13/LICENSE
zstd;https://github.com/mysql/mysql-server/blob/8.0/extra/zstd/zstd-1.5.0/LICENSE
composer_installers;https://github.com/composer/installers/blob/main/LICENSE
mautic_core-lib;https://packagist.org/packages/mautic/core-lib
friendsofphp_php-cs-fixer;https://github.com/PHP-CS-Fixer/PHP-CS-Fixer/blob/master/LICENSE
http-interop_http-factory-guzzle;https://github.com/http-interop/http-factory-guzzle/blob/master/LICENSE
liip_functional-test-bundle;https://github.com/liip/LiipFunctionalTestBundle/blob/master/LICENSE
liip_test-fixtures-bundle;https://github.com/liip/LiipTestFixturesBundle/blob/2.x/LICENSE
mautic_transifex;https://github.com/mautic/Transifex-API/blob/master/LICENSE
phpstan_extension-installer;https://github.com/phpstan/extension-installer/blob/1.2.x/LICENSE
phpstan_phpstan;https://github.com/phpstan/phpstan/blob/1.11.x/LICENSE
phpstan_phpstan-deprecation-rules;https://packagist.org/packages/phpstan/phpstan-deprecation-rules
phpstan_phpstan-doctrine;https://github.com/phpstan/phpstan-doctrine/blob/1.3.x/LICENSE
phpstan_phpstan-php-parser;https://php.libhunt.com/phpstan-alternatives
phpstan_phpstan-phpunit;https://github.com/phpstan/phpstan-phpunit/blob/1.1.x/LICENSE
phpstan_phpstan-symfony;https://github.com/phpstan/phpstan-symfony/blob/1.2.x/LICENSE
phpunit_phpunit;https://github.com/sebastianbergmann/phpunit/blob/main/LICENSE
rector_rector;https://github.com/rectorphp/rector/blob/main/LICENSE
symfony_browser-kit;https://github.com/symfony/browser-kit/blob/6.3/LICENSE
symfony_dom-crawler;https://github.com/symfony/dom-crawler/blob/6.3/LICENSE
symfony_maker-bundle;https://github.com/symfony/maker-bundle/blob/main/LICENSE
symfony_phpunit-bridge;https://github.com/symfony/phpunit-bridge/blob/6.3/LICENSE
symfony_var-dumper;https://github.com/symfony/var-dumper/blob/6.3/LICENSE
symfony_web-profiler-bundle;https://github.com/symfony/web-profiler-bundle/blob/6.3/LICENSE
grunt;https://github.com/gruntjs/grunt/blob/main/LICENSE
grunt-contrib-less;https://github.com/gruntjs/grunt-contrib-less/blob/main/LICENSE-MIT
grunt-contrib-watch;https://github.com/gruntjs/grunt-contrib-watch/blob/main/LICENSE-MIT
patch-package;https://github.com/ds300/patch-package/blob/master/LICENSE
claviska_jquery-minicolors;https://github.com/claviska/jquery-minicolors/blob/master/LICENSE.md
at_js;https://github.com/ichord/At.js/blob/master/LICENSE-MIT
bootstrap;https://github.com/twbs/bootstrap/blob/main/LICENSE
chart_js;https://github.com/chartjs/Chart.js/blob/master/LICENSE.md
chosen-js;https://github.com/harvesthq/chosen/blob/master/LICENSE.md
ckeditor4;https://github.com/ckeditor/ckeditor4/blob/master/LICENSE.md
codemirror;https://github.com/codemirror/codemirror5/blob/master/LICENSE
dropzone;https://github.com/dropzone/dropzone/blob/main/LICENSE
jquery;https://github.com/jquery/jquery/blob/main/LICENSE.txt
jquery-datetimepicker;https://github.com/xdan/datetimepicker/blob/master/MIT-LICENSE.txt
jquery-form;https://github.com/jquery-form/form/blob/master/LICENSE-MIT
jquery-ui;https://github.com/jquery/jquery-ui/blob/main/LICENSE.txt
jquery-ui-touch-punch;https://cdnjs.cloudflare.com/ajax/libs/jqueryui-touch-punch/0.2.3/jquery.ui.touch-punch.min.js
jquery_caret;https://github.com/acdvorak/jquery.caret/blob/master/LICENSE-MIT.txt
jquery_cookie;https://github.com/carhartl/jquery-cookie/blob/master/MIT-LICENSE.txt
jquery_quicksearch;https://github.com/DeuxHuitHuit/quicksearch/blob/master/LICENSE
js-cookie;https://github.com/js-cookie/js-cookie/blob/main/LICENSE
jsplumb;https://github.com/jsplumb/jsplumb
modernizr;https://github.com/Modernizr/Modernizr/blob/master/LICENSE
moment;https://github.com/moment/moment/blob/develop/LICENSE
mousetrap;https://github.com/ccampbell/mousetrap/blob/master/LICENSE
multiselect;https://github.com/davidstutz/bootstrap-multiselect/blob/master/LICENSE.md
shufflejs;https://github.com/Vestride/Shuffle/blob/main/packages/shuffle/LICENSE
typeahead_js;https://github.com/twitter/typeahead.js/blob/master/LICENSE
EOF
end
