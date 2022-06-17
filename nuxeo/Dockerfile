FROM ubuntu:22.04


RUN apt-get update && \
    apt-get dist-upgrade --yes && \
    apt-get install curl git maven openjdk-8-jdk-headless xz-utils --yes
RUN curl -sL https://nodejs.org/dist/v16.15.1/node-v16.15.1-linux-x64.tar.xz -o node.tar.xz
RUN tar xaf node.tar.xz && mv node-v16.15.1-linux-x64 /opt/node
ENV PATH /opt/node/bin/:${PATH}
RUN npm update  --location=global npm
RUN npm install --location=global bower grunt-cli gulp yo

RUN git clone https://github.com/nuxeo/nuxeo.git /opt/nuxeo
WORKDIR /opt/nuxeo
RUN JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64 /usr/bin/mvn -V -B -e test-compile
COPY analyze.sh /opt/nuxeo/
RUN chmod +x analyze.sh
