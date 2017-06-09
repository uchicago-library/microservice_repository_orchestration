#!/bin/bash

set -e

# Set some vars
managers=1
workers=2
# Create manager nodes
for node in $(seq 1 $managers);
do
	docker-machine create -d virtualbox manager$node;
done
# Create the worker nodes
for node in $(seq 1 $workers);
do
	docker-machine create -d virtualbox worker$node;
done
# Init the swarm
docker-machine ssh manager1 "docker swarm init --listen-addr $(docker-machine ip manager1) --advertise-addr $(docker-machine ip manager1)"
# Get the tokens
export manager_token=`docker-machine ssh manager1 "docker swarm join-token manager -q"`
export worker_token=`docker-machine ssh manager1 "docker swarm join-token worker -q"`
# Add the remaining managers
for node in $(seq 2 $managers);
do
	docker-machine ssh manager$node \
		"docker swarm join \
		--token $manager_token \
		--listen-addr $(docker-machine ip manager$node) \
		--advertise-addr $(docker-machine ip manager$node) \
		$(docker-machine ip manager1)"
done
# Add the workers
for node in $(seq 1 $workers);
do
	docker-machine ssh worker$node \
	"docker swarm join \
	--token $worker_token \
	--listen-addr $(docker-machine ip worker$node) \
	--advertise-addr $(docker-machine ip worker$node) \
	$(docker-machine ip manager1):2377"
done
# Start monitor, open in browser
docker-machine ssh manager1 "docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer"
# Bootstrap registry
docker-machine ssh manager1 "docker service create --name registry --publish 5000:5000 registry:2"
# Clone the git repo onto a manager
docker-machine ssh manager1 "git clone https://github.com/bnbalsamo/microservice_repository_orchestration.git"
# Download orchestration repo requirements
docker-machine ssh manager1 "tce-load -wi gettext.tcz"
docker-machine ssh manager1 "cd microservice_repository_orchestration/ && curl -L --fail https://github.com/docker/compose/releases/download/1.13.0/run.sh > docker-compose && chmod +x docker-compose"
# Repo clone script
docker-machine ssh manager1 "cd microservice_repository_orchestration && ./clone_repos.sh"
# Alter config file
docker-machine ssh manager1 "cd microservice_repository_orchestration && mv vars.env vars.env.old && cat vars.env.old | sed 's/SWARM_HOST=.*$/SWARM_HOST=http:\/\/$(docker-machine ip manager1)/' > vars.env"
# Build yml
docker-machine ssh manager1 "cd microservice_repository_orchestration && ./build_swarm_yml.sh"
# Build Images
docker-machine ssh manager1 "cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml build"
# Push
docker-machine ssh manager1 "cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml push"
# Deploy
docker-machine ssh manager1 "cd microservice_repository_orchestration && docker stack deploy --compose-file swarm_stack.yml repository_swarm"
