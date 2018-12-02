FROM ubuntu:latest

RUN echo "Building Teamspeak3 image"
ARG TS_USERNAME
RUN useradd -ms /bin/bash "${TS_USERNAME}"
ARG TS_URL_BZ2
ENV TS_LOCAL_BZ2 /root/teamspeak.tar.bz2
ENV TS_LOCAL_DIR /opt/teamspeak3

RUN export DEBIAN_FRONTEND=noninteractive && apt-get update && apt-get install apt-utils -y &&  apt-get install wget curl bzip2 bash less apt-utils iputils-ping vim iproute2 -y
RUN wget "${TS_URL_BZ2}" -O "${TS_LOCAL_BZ2}"
RUN mkdir "${TS_LOCAL_DIR}" && tar xjf "${TS_LOCAL_BZ2}" -C "${TS_LOCAL_DIR}"
RUN mkdir /persistent
#RUN ln -s "/persistent/ts3server.sqlitedb" "${TS_LOCAL_DIR}/teamspeak3-server_linux_amd64/"
RUN chown -R "${TS_USERNAME}" "${TS_LOCAL_DIR}/teamspeak3-server_linux_amd64/" "/persistent"
USER "${TS_USERNAME}"
WORKDIR "${TS_LOCAL_DIR}/teamspeak3-server_linux_amd64/"
RUN mkdir logs
EXPOSE 9987/udp 30033 10011
ENV TS3SERVER_LICENSE accept

ENTRYPOINT ["./ts3server_minimal_runscript.sh"]
