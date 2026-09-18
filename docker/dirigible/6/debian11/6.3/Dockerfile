# Copyright 2022 Google LLC
#
# All rights reserved. This program and the accompanying materials
# are made available under the terms of the Eclipse Public License v2.0
# which accompanies this distribution, and is available at
# http://www.eclipse.org/legal/epl-v20.html


FROM dirigiblelabs/dirigible-all:6.3.26 AS build

FROM marketplace.gcr.io/google/debian11

ENV C2D_RELEASE 6.3.26

COPY --from=build /usr/local/tomcat/ /usr/local/tomcat/

EXPOSE 8080

ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "jpda", "run"]
