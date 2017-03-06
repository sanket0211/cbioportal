FROM tomcat:8-jre8
MAINTAINER Alexandros Sigaras <als2076@med.cornell.edu>
LABEL Description="cBioPortal for Cancer Genomics"
ENV APP_NAME="cbioportal" \
    PORTAL_HOME="/cbioportal" \
    MVN_VERSION="3.3.9" \
    M2_HOME="/usr/local/apache-maven" \
    M2="/usr/local/apache-maven/bin"
ENV PATH $M2:$PATH
#======== Install Required Components ===============#
RUN apt-get update && apt-get install -y --no-install-recommends \
        git \
        libmysql-java \
        openjdk-8-jdk \
        python \
        python-jinja2 \
        python-mysqldb \
        python-requests \
    && mkdir /root/.m2/ \
    && cd /opt/ \
    && wget http://mirror.reverse.net/pub/apache/maven/maven-3/${MVN_VERSION}/binaries/apache-maven-${MVN_VERSION}-bin.tar.gz \
    && tar xzf /opt/apache-maven-${MVN_VERSION}-bin.tar.gz \
    && mv apache-maven-${MVN_VERSION} /usr/local/apache-maven \
    && ln -s /usr/share/java/mysql-connector-java.jar "$CATALINA_HOME"/lib/ \
    && rm -rf $CATALINA_HOME/webapps/examples \
    && rm -rf /var/lib/apt/lists/*
#======== Configure cBioPortal ===========================#
COPY . $PORTAL_HOME
WORKDIR $PORTAL_HOME
EXPOSE 8080
#======== Build cBioPortal on Startup ===============#
CMD mvn -DskipTests clean install \
     && cp $PORTAL_HOME/portal/target/cbioportal-*-SNAPSHOT.war $CATALINA_HOME/webapps/cbioportal.war \
     && sh $CATALINA_HOME/bin/catalina.sh run