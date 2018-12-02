# automated-docker-teamspeak3
## Script Help menu
``` 
Usage: build-run.sh [--help]|[--build][--run]
Options:
   * --help:  show the help menu.
   * --build: build all the layers and fetch the last version of teamspeak3 on the website (default version is: http://dl.4players.de/ts/releases/3.4.0/teamspeak3-server_linux_amd64-3.4.0.tar.bz2).
   * --run: run the container with the default parameters

Pre-requisites (will be set as parameter in further updates):
   * mkdir -p /data/docker/volumes/teamspeak/logs/ /data/docker/volumes/teamspeak/
   * create or reuse your sqlite DB (default name: ts3server.sqlitedb) and add it to /data/docker/volumes/teamspeak/
   * create query_ip_blacklist.txt and it to /data/docker/volumes/teamspeak/
```
