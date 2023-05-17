FROM openjdk:8-bullseye

LABEL maintainer="javen <javenlxx@gmail.com>" version="8.10.0"

ARG BITBUCKET_VERSION=8.10.0
# Production: jira-software jira-core
ARG BITBUCKET_PRODUCT=jira-software
ARG AGENT_VERSION=1.3.3

ENV BITBUCKET_USER=bitbucket \
    BITBUCKET_GROUP=bitbucket \
    BITBUCKET_HOME=/var/bitbucket \
    BITBUCKET_INSTALL=/opt/bitbucket \
    JVM_MINIMUM_MEMORY=1g \
    JVM_MAXIMUM_MEMORY=3g \
    JVM_CODE_CACHE_ARGS='-XX:InitialCodeCacheSize=1g -XX:ReservedCodeCacheSize=2g' \
    AGENT_PATH=/var/agent \
    AGENT_FILENAME=atlassian-agent.jar

ENV JAVA_OPTS="-javaagent:${AGENT_PATH}/${AGENT_FILENAME} ${JAVA_OPTS}"

RUN mkdir -p ${BITBUCKET_INSTALL} ${BITBUCKET_HOME} ${AGENT_PATH} \
&& curl -o ${AGENT_PATH}/${AGENT_FILENAME}  https://github.com/haxqer/jira/releases/download/v${AGENT_VERSION}/atlassian-agent.jar -L \
&& curl -o /tmp/atlassian.tar.gz https://product-downloads.atlassian.com/software/stash/downloads/atlassian-bitbucket-${BITBUCKET_VERSION}.tar.gz -L \
&& tar xzf /tmp/atlassian.tar.gz -C ${BITBUCKET_INSTALL}/ --strip-components 1 \
&& rm -f /tmp/atlassian.tar.gz 
# && echo "jira.home = ${BITBUCKET_HOME}" > ${BITBUCKET_INSTALL}/atlassian-jira/WEB-INF/classes/jira-application.properties

RUN export CONTAINER_USER=$BITBUCKET_USER \
&& export CONTAINER_GROUP=$BITBUCKET_GROUP \
&& groupadd -r $BITBUCKET_GROUP && useradd -r -g $BITBUCKET_GROUP $BITBUCKET_USER \
&& chown -R $BITBUCKET_USER:$BITBUCKET_GROUP ${BITBUCKET_INSTALL} ${BITBUCKET_HOME} ${AGENT_PATH}

VOLUME $BITBUCKET_HOME
USER $BITBUCKET_USER
WORKDIR $BITBUCKET_INSTALL
EXPOSE 7990 7999

ENTRYPOINT ["/opt/atlassian/bitbucket/bin/start-bitbucket.sh", "-fg"]