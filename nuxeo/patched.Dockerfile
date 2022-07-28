FROM nuxeo


COPY ./patches /patches
WORKDIR /opt/nuxeo
RUN git config --global user.email "validation@lt.sonar" && \
    git config --global user.name "Validation Build"
RUN git switch --create patch-modified
RUN git am /patches/0001-Simple-patch-on-a-single-file-that-introdcues-a-DBD-.patch
RUN JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 /usr/bin/mvn -V -B -e test-compile
COPY analyze.sh /opt/nuxeo/
RUN chmod +x analyze.sh