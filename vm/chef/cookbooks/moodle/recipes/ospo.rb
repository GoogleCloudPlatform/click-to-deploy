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
https://github.com/moodle/moodle.git
EOF
  licenses <<-EOF
Moodle;https://github.com/moodle/moodle/blob/master/COPYING.txt
behat_behat;https://github.com/Behat/Behat/blob/master/LICENSE
behat_gherkin;https://github.com/Behat/Gherkin/blob/master/LICENSE
behat_mink;https://github.com/behat/mink/blob/master/LICENSE
behat_mink-browserkit-driver;https://github.com/minkphp/MinkBrowserKitDriver/blob/master/LICENSE
behat_mink-goutte-driver;https://github.com/minkphp/MinkGoutteDriver/blob/master/LICENSE
behat_transliterator;https://github.com/behat/transliterator/blob/master/LICENSE
doctrine_instantiator;https://github.com/doctrine/instantiator/blob/2.0.x/LICENSE
fabpot_goutte;https://github.com/FriendsOfPHP/Goutte/blob/master/LICENSE
friends-of-behat_mink-extension;https://github.com/FriendsOfBehat/MinkExtension/blob/master/LICENSE
mikey179_vfsstream;https://github.com/bovigo/vfsStream/blob/master/LICENSE
myclabs_deep-copy;https://github.com/myclabs/DeepCopy/blob/1.x/LICENSE
nikic_php-parser;https://github.com/nikic/php-parser/blob/master/LICENSE
oleg-andreyev_mink-phpwebdriver;https://github.com/oleg-andreyev/MinkPhpWebDriver/blob/master/LICENSE
phar-io_manifest;https://github.com/phar-io/manifest/blob/master/LICENSE
phar-io_version;https://github.com/phar-io/version/blob/master/LICENSE
php-webdriver_webdriver;https://github.com/php-webdriver/php-webdriver/blob/main/LICENSE.md
phpunit_php-code-coverage;https://github.com/sebastianbergmann/php-code-coverage/blob/main/LICENSE
phpunit_php-file-iterator;https://github.com/sebastianbergmann/php-file-iterator/blob/main/LICENSE
phpunit_php-invoker;https://github.com/sebastianbergmann/php-invoker/blob/main/LICENSE
phpunit_php-text-template;https://github.com/sebastianbergmann/php-text-template/blob/main/LICENSE
phpunit_php-timer;https://github.com/sebastianbergmann/php-timer/blob/main/LICENSE
phpunit_phpunit;https://github.com/sebastianbergmann/phpunit/blob/main/LICENSE
psr_container;https://github.com/php-fig/container/blob/master/LICENSE
psr_event-dispatcher;https://github.com/php-fig/event-dispatcher/blob/master/LICENSE
psr_log;https://github.com/php-fig/log/blob/master/LICENSE
sebastian_cli-parser;https://github.com/sebastianbergmann/cli-parser/blob/main/LICENSE
sebastian_code-unit;https://github.com/sebastianbergmann/code-unit/blob/main/LICENSE
sebastian_code-unit-reverse-lookup;https://github.com/sebastianbergmann/code-unit-reverse-lookup/blob/main/LICENSE
sebastian_comparator;https://github.com/sebastianbergmann/comparator/blob/main/LICENSE
sebastian_complexity;https://github.com/sebastianbergmann/complexity/blob/main/LICENSE
sebastian_diff;https://github.com/sebastianbergmann/diff/blob/main/LICENSE
sebastian_environment;https://github.com/sebastianbergmann/environment/blob/main/LICENSE
sebastian_exporter;https://github.com/sebastianbergmann/exporter/blob/main/LICENSE
sebastian_global-state;https://github.com/sebastianbergmann/global-state/blob/main/LICENSE
sebastian_lines-of-code;https://github.com/sebastianbergmann/lines-of-code/blob/main/LICENSE
sebastian_object-enumerator;https://github.com/sebastianbergmann/object-enumerator/blob/main/LICENSE
sebastian_object-reflector;https://github.com/sebastianbergmann/object-reflector/blob/main/LICENSE
sebastian_recursion-context;https://github.com/sebastianbergmann/recursion-context/blob/main/LICENSE
sebastian_resource-operations;https://github.com/sebastianbergmann/resource-operations/blob/main/LICENSE
sebastian_type;https://github.com/sebastianbergmann/type/blob/main/LICENSE
sebastian_version;https://github.com/sebastianbergmann/version/blob/main/LICENSE
symfony_browser-kit;https://github.com/symfony/browser-kit/blob/6.3/LICENSE
symfony_config;https://github.com/symfony/config/blob/6.3/LICENSE
symfony_console;https://github.com/symfony/console/blob/6.3/LICENSE
symfony_css-selector;https://github.com/symfony/css-selector/blob/6.3/LICENSE
symfony_dependency-injection;https://github.com/symfony/dependency-injection/blob/6.3/LICENSE
symfony_deprecation-contracts;https://github.com/symfony/deprecation-contracts/blob/main/LICENSE
symfony_dom-crawler;https://github.com/symfony/dom-crawler/blob/6.3/LICENSE
symfony_event-dispatcher;https://github.com/symfony/event-dispatcher/blob/6.3/LICENSE
symfony_event-dispatcher-contracts;https://github.com/symfony/event-dispatcher-contracts/blob/main/LICENSE
symfony_filesystem;https://github.com/symfony/filesystem/blob/6.3/LICENSE
symfony_http-client;https://github.com/symfony/http-client/blob/6.3/LICENSE
symfony_http-client-contracts;https://github.com/symfony/http-client-contracts/blob/main/LICENSE
symfony_mime;https://github.com/symfony/mime/blob/6.3/LICENSE
symfony_polyfill-ctype;https://github.com/symfony/polyfill-ctype/blob/main/LICENSE
symfony_polyfill-intl-grapheme;https://github.com/symfony/polyfill-intl-grapheme/blob/main/LICENSE
symfony_polyfill-intl-idn;https://github.com/symfony/polyfill-intl-idn/blob/main/LICENSE
symfony_polyfill-intl-normalizer;https://github.com/symfony/polyfill-intl-normalizer/blob/main/LICENSE
symfony_polyfill-mbstring;https://github.com/symfony/polyfill-mbstring/blob/main/LICENSE
symfony_polyfill-php72;https://github.com/symfony/polyfill-php72/blob/main/LICENSE
symfony_polyfill-php73;https://github.com/symfony/polyfill-php73/blob/main/LICENSE
symfony_polyfill-php80;https://github.com/symfony/polyfill-php80/blob/main/LICENSE
symfony_polyfill-php81;https://github.com/symfony/polyfill-php81/blob/main/LICENSE
symfony_process;https://github.com/symfony/process/blob/6.3/LICENSE
symfony_service-contracts;https://github.com/symfony/service-contracts/blob/main/LICENSE
symfony_string;https://github.com/symfony/string/blob/6.3/LICENSE
symfony_translation;https://github.com/symfony/translation/blob/6.3/LICENSE
symfony_translation-contracts;https://github.com/symfony/translation-contracts/blob/main/LICENSE
symfony_yaml;https://github.com/symfony/yaml/blob/6.3/LICENSE
theseer_tokenizer;https://github.com/theseer/tokenizer/blob/master/LICENSE
EOF
end
