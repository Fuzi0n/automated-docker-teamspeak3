#!/bin/bash
# vim: tabstop=2 shiftwidth=2 expandtab

TS_CONTAINER_NAME="teamspeak3"

TS_URL="http://dl.4players.de/ts/releases/3.4.0/teamspeak3-server_linux_amd64-3.4.0.tar.bz2"

TS_URL_REGEX="http://.*teamspeak3-server_linux_amd64.*.bz2\">"

Usage () {

    cat <<HELP_USAGE

Usage: `basename $0` [--help]|[--build][--run] 
Options:
   * --help:  show the help menu.
   * --build: build all the layers and fetch the last version of teamspeak3 on the website (default version is: $TS_URL).
   * --run: run the container with the default parameters

Pre-requisites (will be set as parameter in further updates):
   * mkdir -p /data/docker/volumes/teamspeak/logs/ /data/docker/volumes/teamspeak/
   * create or reuse your sqlite DB (default name: ts3server.sqlitedb) and add it to /data/docker/volumes/teamspeak/
   * create query_ip_blacklist.txt and it to /data/docker/volumes/teamspeak/ 
   
HELP_USAGE
}

function GetNewRelease {

	TS_RELEASE=$(curl -s "https://www.teamspeak.com/en/downloads/" | egrep -o "$TS_URL_REGEX" | cut -d "=" -f2 | sed 's/>//g; s/\"//g')

	if [ -z "$TS_RELEASE" ]; then
		TS_RELEASE="$TS_URL"
	fi

	echo "------------- Using teamspeak3 image $TS_RELEASE (default is: $TS_URL)"

}


function BackupDB {

        local DB_SOURCE_PATH=$1
        local DB_DEST_PATH=$2

        if [ -e "$DB_SOURCE_PATH" ];then
             cp  "$DB_SOURCE_PATH" "$DB_DEST_PATH/ts3server.sqlitedb_$(date +%s)"
	else	
	     echo "[WARNING] no database found at: "$DB_SOURCE_PATH""
	fi
}

function BuildImage {

    if [ -f "Dockerfile" ];then
	     docker build --pull --build-arg TS_USERNAME="$TS_CONTAINER_NAME" --build-arg TS_URL_BZ2="$TS_RELEASE" -t "$TS_CONTAINER_NAME" .
    else
	    echo "[ERROR]: No Dockerfile found in $CWD"
    fi

}

function CreateImage { 

	docker ps -a | grep "$TS_CONTAINER_NAME"
	if [ $? -eq 0 ];then
	    docker stop "$TS_CONTAINER_NAME"
            docker rm "$TS_CONTAINER_NAME"
	fi

	docker create --name "$TS_CONTAINER_NAME" --net=host -v /etc/localtime:/etc/locatime:ro -v /etc/timezone:/etc/timezone:ro -v /data/docker/volumes/teamspeak/ts3server.sqlitedb:/opt/teamspeak3/teamspeak3-server_linux_amd64/ts3server.sqlitedb:rw -v /data/docker/volumes/teamspeak/logs/:/opt/teamspeak3/teamspeak3-server_linux_amd64/logs:rw -v /data/docker/volumes/teamspeak/query_ip_blacklist.txt:/opt/teamspeak3/teamspeak3-server_linux_amd64/query_ip_blacklist.txt:rw -v /data/docker/volumes/teamspeak/query_ip_whitelist.txt:/opt/teamspeak3/teamspeak3-server_linux_amd64/query_ip_whitelist.txt:rw -t "$TS_CONTAINER_NAME" 

}

if [ "${#@}" -eq 0 ] || [ "$1" == "--help" ]; then
    Usage
    exit 1
fi

if [ "$1" == "--build" ]; then
    GetNewRelease
    BuildImage 
fi

if [ "$1" == "--run" ]; then
	CreateImage
	BackupDB "/data/docker/volumes/teamspeak/ts3server.sqlitedb" "/data/docker/volumes/teamspeak/backup/"
	docker stop "$TS_CONTAINER_NAME"
	docker start "$TS_CONTAINER_NAME"
fi
