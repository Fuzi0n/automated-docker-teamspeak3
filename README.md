# automated-docker-teamspeak3
# Prerequisites
* python>=3.6
* docker-ce>=17.04
* sudo privilegies to run docker command
* poetry=>1.1.x
* optional: python3-virtualenv

# Install python3 required modules
```
pip3 install -r requirements.txt
```

# Playbook configuration
You can configure parameters in ansible/groups_vars/all or ansible/host_vars/localhost
```
...
docker_ts_container_home: /opt/teamspeak3
docker_ts_username: "{{ ts_container_name }}"
docker_ts_expose_port_service: 9987
docker_ts_expose_port_filetransfer: 30033
docker_ts_expose_port_server_query: 10011
...

````
If you already have a working Teamspeak SQlite database you can bind it inside the container with parameter:
```
ts_database_local_path: <docker_host_local_path>
```
## Usage
``` 
$ cd ansible
$ poetry run ansible-playbook -i inventory --limit localhost deploy-teamspeak.yml
```
