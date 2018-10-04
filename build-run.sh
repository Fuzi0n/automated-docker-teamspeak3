#!/bin/bash

TS_CONTAINER_NAME="teamspeak3"

TS_URL="http://dl.4players.de/ts/releases/3.4.0/teamspeak3-server_linux_amd64-3.4.0.tar.bz2"


function GetNewRelease {
	TS_RELEASE=$(curl -s "https://www.teamspeak.com/en/downloads/" | egrep -o "href=\"http://.*teamspeak3-server_linux_amd64.*.bz2\">" | cut -d "=" -f2 | sed 's/>//g; s/\"//g')
	if [ -n "$TS_RELEASE" ]; then
		TS_URL="$TS_RELEASE"
	fi

}


function BackupDB {

        local DB_SOURCE_PATH=$1
        local DB_DEST_PATH=$2

        if [ -e "$DB_SOURCE_PATH" ];then
             cp  "$DB_SOURCE_PATH" "$DB_DEST_PATH/ts3server.sqlitedb_$(date +%s)"
	fi
}

function BuildImage {
    if [ -f "Dockerfile" ];then
	     docker build --force-rm=true --pull --build-arg TS_USERNAME="$TS_CONTAINER_NAME" --build-arg TS_URL_BZ2="$TS_URL" -t "$TS_CONTAINER_NAME" .
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
	docker create --name "$TS_CONTAINER_NAME" --net=host -v /etc/timezone:/etc/timezone:ro -v /data/docker/volumes/teamspeak/ts3server.sqlitedb:/opt/teamspeak3/teamspeak3-server_linux_amd64/ts3server.sqlitedb:rw -v /data/docker/volumes/teamspeak/logs/:/opt/teamspeak3/teamspeak3-server_linux_amd64/logs:rw -v /data/docker/volumes/teamspeak/query_ip_blacklist.txt:/opt/teamspeak3/teamspeak3-server_linux_amd64/query_ip_blacklist.txt:rw -v /data/docker/volumes/teamspeak/query_ip_whitelist.txt:/opt/teamspeak3/teamspeak3-server_linux_amd64/query_ip_whitelist.txt:rw -t "$TS_CONTAINER_NAME" 

}

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
