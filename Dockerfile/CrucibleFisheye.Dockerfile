FROM openjdk:8-bullseye

LABEL maintainer="javen <javenlxx@gmail.com>" version="8.10.0"

ARG FISHEYE_VERSION=4.8.11
ARG AGENT_VERSION=1.3.3

ENV HOME=/opt/fecru \
    AGENT_PATH=/var/agent \
    AGENT_FILENAME=atlassian-agent.jar

RUN mkdir -p ${AGENT_PATH} \
&& curl -o ${AGENT_PATH}/${AGENT_FILENAME}  https://github.com/haxqer/jira/releases/download/v${AGENT_VERSION}/atlassian-agent.jar -L \
&& curl -o /tmp/atlassian.zip https://product-downloads.atlassian.com/software/crucible/downloads/crucible-${FISHEYE_VERSION}.zip -L\
&& unzip /tmp/atlassian.zip -d /opt \
&& mv /opt/fecru-${FISHEYE_VERSION}/ ${HOME}/ \
&& rm -f /tmp/atlassian.tar.gz \
&& sed -i 's/CMD="$JAVACMD $FISHEYE_OPTS/CMD="$JAVACMD $FISHEYE_OPTS -javaagent:${AGENT_PATH}\/${AGENT_FILENAME}/g' ${HOME}/bin/fisheyectl.sh

WORKDIR $HOME
EXPOSE 8060

ENTRYPOINT ["/opt/fecru/bin/run.sh"]