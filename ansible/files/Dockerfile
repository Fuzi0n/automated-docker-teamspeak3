FROM ubuntu:latest

ARG TS_CONTAINER_HOME
ARG TS_USERNAME
RUN useradd -ms /bin/bash "${TS_USERNAME}"
ARG TS_URL_BZ2
ENV TS_LOCAL_BZ2 /root/teamspeak.tar.bz2
RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install apt-utils -y &&  apt-get install wget curl bzip2 bash less apt-utils iputils-ping vim iproute2 -y && apt-get clean
RUN wget "${TS_URL_BZ2}" -O "${TS_LOCAL_BZ2}"
RUN mkdir "${TS_CONTAINER_HOME}" && tar xjf "${TS_LOCAL_BZ2}" -C "${TS_CONTAINER_HOME}" && rm "$TS_LOCAL_BZ2"
RUN chown -R "${TS_USERNAME}" "${TS_CONTAINER_HOME}/teamspeak3-server_linux_amd64/"
USER "${TS_USERNAME}"
WORKDIR "${TS_CONTAINER_HOME}/teamspeak3-server_linux_amd64/"
RUN mkdir logs
ENV TS3SERVER_LICENSE accept

ENTRYPOINT ["./ts3server_minimal_runscript.sh"]
