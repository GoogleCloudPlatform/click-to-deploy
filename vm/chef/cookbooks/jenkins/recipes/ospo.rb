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
https://github.com/openjdk/jdk.git
https://github.com/spotbugs/spotbugs.git
https://github.com/jakartaee/common-annotations-api.git
https://github.com/jakartaee/tags.git
https://github.com/javaee/javax.annotation.git
https://github.com/jglick/sezpoz.git
https://github.com/jfree/jcommon.git
https://github.com/jfree/jfreechart.git
https://github.com/kohsuke/tiger-types.git
https://github.com/codelibs/jcifs
https://github.com/javaee/jaxb-v2.git
EOF
  licenses <<-EOF
Jenkins;https://github.com/jenkinsci/jenkins/blob/master/LICENSE.txt
Apache_httpd;https://github.com/apache/httpd/blob/trunk/LICENSE
Openjdk11;https://github.com/openjdk/jdk/blob/master/LICENSE
cli;https://github.com/jenkinsci/jenkins/blob/master/LICENSE.txt
jenkins-core;https://github.com/jenkinsci/jenkins/blob/master/LICENSE.txt
remoting;https://github.com/jenkinsci/remoting/blob/master/LICENSE.md
websocket-jetty10;https://github.com/jenkinsci/jenkins/blob/master/LICENSE.txt
websocket-jetty9;https://github.com/jetty-project/embedded-jetty-websocket-examples/blob/9.4.x/LICENSE
slf4j-jdk14;https://github.com/qos-ch/slf4j/blob/master/LICENSE.txt
args4j;https://github.com/kohsuke/args4j/blob/master/args4j/LICENSE.txt
spotbugs-annotations;https://github.com/spotbugs/spotbugs/blob/master/LICENSE
failureaccess;https://github.com/google/guava/blob/master/LICENSE
guava;https://github.com/google/guava/blob/master/LICENSE
listenablefuture;https://github.com/google/guava/blob/master/LICENSE
guice;https://github.com/google/guice/blob/master/COPYING
bridge-method-annotation;https://mvnrepository.com/artifact/com.infradna.tool/bridge-method-annotation
jzlib;https://github.com/ymnk/jzlib/blob/master/LICENSE.txt
embedded_su4j;http://www.java2s.com/example/jar/e/download-embeddedsu4j11jar-file.html
txw2;https://github.com/javaee/jaxb-v2/blob/master/LICENSE
xstream;https://github.com/x-stream/xstream/blob/master/LICENSE.txt
commons-beanutils;https://github.com/apache/commons-beanutils/blob/master/LICENSE.txt
commons-codec;https://github.com/apache/commons-codec/blob/master/LICENSE.txt
commons-collections;https://github.com/apache/commons-collections/blob/master/LICENSE.txt
commons-discovery;https://github.com/sakaiproject/sakai/blob/master/licenses/commons-discovery-0.2.license.txt
commons-fileupload;https://github.com/apache/commons-fileupload/blob/master/LICENSE.txt
commons-io;https://github.com/apache/commons-io/blob/master/LICENSE.txt
commons-jelly-tags-fmt;https://github.com/apache/commons-jelly/blob/master/LICENSE.txt
commons-jelly-tags-xml;https://github.com/apache/commons-jelly/blob/master/LICENSE.txt
commons-lang;https://github.com/apache/commons-lang/blob/master/LICENSE.txt
commons-logging;https://github.com/apache/commons-logging/blob/master/LICENSE.txt
jenkins-stapler-support;https://github.com/jenkinsci/lib-jenkins-stapler-support/blob/master/src/main/java/jenkins/security/stapler/StaplerAccessibleType.java
jakarta.annotation-api;https://github.com/jakartaee/common-annotations-api/blob/master/LICENSE.md
jakarta.servlet.jsp.jstl-api;https://github.com/jakartaee/tags/blob/master/LICENSE.md
javax.annotation-api;https://github.com/javaee/javax.annotation/blob/master/LICENSE
javax.inject;https://github.com/javax-inject/javax-inject
jaxen;https://github.com/jaxen-xpath/jaxen/blob/master/LICENSE.txt
jline;https://github.com/jline/jline3/blob/master/LICENSE.txt
jna;https://github.com/java-native-access/jna/blob/master/LICENSE
sezpoz;https://github.com/jglick/sezpoz/blob/master/pom.xml
jcip-annotations;https://github.com/stephenc/jcip-annotations/blob/master/LICENSE.txt
ezmorph;https://github.com/kordamp/ezmorph/blob/master/LICENSE
kxml2;https://github.com/kobjects/kxml2/blob/master/license.txt
antlr4-runtime;https://github.com/antlr/antlr4/blob/dev/LICENSE.txt
ant;https://github.com/apache/ant/blob/master/LICENSE
ant-launcher;https://github.com/apache/ant/blob/master/LICENSE
commons-compress;https://github.com/apache/commons-compress/blob/master/LICENSE.txt
groovy-all;https://github.com/apache/groovy/blob/master/LICENSE
jbcrypt;https://github.com/jeremyh/jBCrypt/blob/master/LICENSE
dom4j;https://github.com/dom4j/dom4j/blob/master/LICENSE
jansi;https://github.com/fusesource/jansi/blob/master/license.txt
annotation-indexer;https://mvnrepository.com/artifact/org.jenkins-ci/annotation-indexer/1.12
commons-jelly;https://github.com/apache/commons-jelly/blob/master/LICENSE.txt
commons-jexl;https://github.com/apache/commons-jexl/blob/master/LICENSE.txt
crypto-util;https://github.com/sop/crypto-util/blob/master/LICENSE
memory-monitor;https://github.com/pd4d10/memory-monitor/blob/master/LICENSE
symbol-annotation;https://github.com/jenkinsci/lib-symbol-annotation/blob/master/pom.xml
task-reactor;https://github.com/jenkinsci/lib-task-reactor
version-number;https://github.com/jenkinsci/lib-version-number/blob/master/LICENSE.txt
websocket-spi;https://github.com/jenkinsci/websocket-plugin
jcommon;https://github.com/jfree/jcommon/blob/master/LICENSE
jfreechart;https://github.com/jfree/jfreechart/blob/master/licence-LGPL.txt
tiger-types;https://github.com/kohsuke/tiger-types/blob/master/pom.xml
commons-jelly-tags-define;https://github.com/apache/commons-jelly/blob/master/LICENSE.txt
localizer;https://mvnrepository.com/artifact/org.jvnet.localizer/maven-localizer-plugin/1.24
robust-http-client;https://mvnrepository.com/artifact/org.jvnet.robust-http-client/robust-http-client/1.1
winp;https://github.com/jenkinsci/winp/blob/master/LICENSE.txt
access-modifier-annotation;https://github.com/jenkinsci/lib-access-modifier/blob/master/LICENSE.md
windows-package-checker;http://windows-package-checker.kohsuke.org/license.html
j-interop;https://mvnrepository.com/artifact/org.kohsuke.jinterop/j-interop
j-interopdeps;https://mvnrepository.com/artifact/org.kohsuke.jinterop/j-interopdeps
metainf-services;https://mvnrepository.com/artifact/org.kohsuke.metainf-services/metainf-services
json-lib;https://github.com/kordamp/json-lib/blob/master/LICENSE
stapler;https://github.com/jenkinsci/stapler/blob/master/LICENSE.txt
stapler-adjunct-codemirror;https://mvnrepository.com/artifact/org.kohsuke.stapler/stapler-adjunct-codemirror/1.3
stapler-adjunct-timeline;https://github.com/stapler/stapler-adjunct-timeline/blob/master/LICENSE.txt
stapler-groovy;https://mvnrepository.com/artifact/org.kohsuke.stapler/stapler-groovy
stapler-jelly;https://github.com/jenkinsci/stapler/blob/master/LICENSE.txt
asm;https://asm.ow2.io/license.html
asm-analysis;https://mvnrepository.com/artifact/org.ow2.asm/asm-analysis
asm-commons;https://mvnrepository.com/artifact/org.ow2.asm/asm-commons
asm-tree;https://mvnrepository.com/artifact/org.ow2.asm/asm-tree
asm-util;https://mvnrepository.com/artifact/org.ow2.asm/asm-util/6.2.1
jcifs;https://github.com/codelibs/jcifs/blob/master/LICENSE
jcl-over-slf4j;https://github.com/qos-ch/slf4j/blob/master/jcl-over-slf4j/LICENSE.txt
log4j-over-slf4j;https://mvnrepository.com/artifact/org.slf4j/log4j-over-slf4j
slf4j-api;https://mvnrepository.com/artifact/org.slf4j/slf4j-api
spring-aop;https://github.com/hqrd/Spring-AOP-Example/blob/master/LICENSE
spring-beans;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
spring-context;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
spring-core;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
spring-expression;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
spring-web;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
spring-security-core;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
spring-security-crypto;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
spring-security-web;https://github.com/spring-projects/spring-framework/blob/main/LICENSE.txt
relaxngDatatype;https://github.com/java-schema-utilities/relaxng-datatype-java/blob/master/pom.xml
xpp3;https://mvnrepository.com/artifact/org.ogce/xpp3
EOF
end
