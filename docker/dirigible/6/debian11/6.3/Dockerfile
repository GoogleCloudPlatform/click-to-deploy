FROM dirigiblelabs/dirigible-all AS build


FROM marketplace.gcr.io/google/debian11

COPY --from=build /usr/local/tomcat/ /usr/local/tomcat/

EXPOSE 8080

ENTRYPOINT ["/usr/local/tomcat/bin/catalina.sh", "jpda", "run"]