#!/bin/bash
set -e
# Swarm microservice repository demo
# Note: Sometimes DO can die while provisioning DO
# instances, see: https://github.com/docker/machine/issues/3358
# Set some vars
managers=1
workers=2
# Check to be sure we have a token
: "${DIGITALOCEAN_ACCESS_TOKEN:?Must supply a Digital Ocean token in the DIGITALOCEAN_ACCESS_TOKEN env variable}"
# Create manager nodes
for node in $(seq 1 $managers);
do
	docker-machine create \
            -d digitalocean \
            --digitalocean-access-token=$DIGITALOCEAN_ACCESS_TOKEN \
            --digitalocean-size 2gb \
            ni-manager$node;
done
# Create the worker nodes
for node in $(seq 1 $workers);
do
	docker-machine create \
            -d digitalocean \
            --digitalocean-access-token=$DIGITALOCEAN_ACCESS_TOKEN \
            --digitalocean-size 2gb \
            ni-worker$node;
done
# Init the swarm
docker-machine ssh ni-manager1 "docker swarm init --listen-addr $(docker-machine ip ni-manager1) --advertise-addr $(docker-machine ip ni-manager1)"
# Get the tokens
export ni_manager_token=`docker-machine ssh ni-manager1 "docker swarm join-token manager -q"`
export ni_worker_token=`docker-machine ssh ni-manager1 "docker swarm join-token worker -q"`
# Add the remaining managers
for node in $(seq 2 $managers);
do
	docker-machine ssh ni-manager$node \
		"docker swarm join \
		--token $ni_manager_token \
		--listen-addr $(docker-machine ip ni-manager$node) \
		--advertise-addr $(docker-machine ip ni-manager$node) \
		$(docker-machine ip ni-manager1)"
done
# Add the workers
for node in $(seq 1 $workers);
do
	docker-machine ssh ni-worker$node \
	"docker swarm join \
	--token $ni_worker_token \
	--listen-addr $(docker-machine ip ni-worker$node) \
	--advertise-addr $(docker-machine ip ni-worker$node) \
	$(docker-machine ip ni-manager1):2377"
done
docker-machine ssh ni-manager1 "docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer"
docker-machine ssh ni-manager1 "docker service create --name registry --publish 5000:5000 registry:2"
# Clone the git repo onto a manager
docker-machine ssh ni-manager1 "git clone https://github.com/bnbalsamo/microservice_repository_orchestration.git"
# Download orchestration repo requirements
docker-machine ssh ni-manager1 "cd microservice_repository_orchestration/ && curl -L --fail https://github.com/docker/compose/releases/download/1.13.0/run.sh > docker-compose && chmod +x docker-compose"
docker-machine ssh manager1 "tce-load -wi gettext.tcz"
# Repo clone script
docker-machine ssh ni-manager1 "cd microservice_repository_orchestration && sh clone_repos.sh"
# Alter config file
docker-machine ssh ni-manager1 "cd microservice_repository_orchestration && mv vars.env vars.env.old && cat vars.env.old | sed 's/SWARM_HOST=.*$/SWARM_HOST=http:\/\/$(docker-machine ip ni-manager1)/' > vars.env"
# Build yml
docker-machine ssh ni-manager1 "cd microservice_repository_orchestration && sh build_swarm_yml.sh"
# Build Images
docker-machine ssh ni-manager1 "cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml build"
# Push
docker-machine ssh ni-manager1 "cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml push"
# Deploy
docker-machine ssh ni-manager1 "cd microservice_repository_orchestration && docker stack deploy --compose-file swarm_stack.yml repository_swarm"
