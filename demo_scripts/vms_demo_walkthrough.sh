#!/bin/bash


set -e

# Swarm microservice repository demo

# Set some vars
managers=1
workers=2
EXPLANATORY="======>"


# Intro
echo "$EXPLANATORY First things first, lets build our swarm."
echo "$EXPLANATORY This demo builds a swarm from VMs "
echo "$EXPLANATORY utilizing docker-machine. If you "
echo "$EXPLANATORY don't have docker-machine installed, "
echo "$EXPLANATORY hit Ctrl+C now and install it."
read


echo "$EXPLANATORY First things first, lets build our VMs"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Create manager nodes
echo "$EXPLANATORY About to create the manager nodes"
echo "$EXPLANATORY $ docker-machine create manager\$x"
echo "$EXPLANATORY Hit Enter to Execute the Command for each Manager"
read
echo "$EXPLANATORY Creating $managers manager machines ...";
for node in $(seq 1 $managers);
do
	echo "$EXPLANATORY Creating manager$node machine ...";
	docker-machine create \
            manager$node;
done
echo "$EXPLANATORY Managers created!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Create the worker nodes
echo "$EXPLANATORY About to create the worker nodes"
echo "$EXPLANATORY $ docker-machine create worker\$x"
echo "$EXPLANATORY Hit Enter to Execute the Command for each Worker"
read
echo "$EXPLANATORY Creating $workers worker machines ...";
for node in $(seq 1 $workers);
do
	echo "$EXPLANATORY Creating worker$node machine ...";
	docker-machine create \
            worker$node;
done
echo "$EXPLANATORY Workers created!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Display machines
echo "$EXPLANATORY Our machines are now configured, lets take a look..."
echo "$EXPLANATORY $ docker-machine ls"
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ls
echo "$EXPLANATORY Hit Enter to Continue"
read


# Init the swarm
echo "$EXPLANATORY Now that our nodes exist, it's time to introduce"
echo "$EXPLANATORY them to each other, and get them all set up as "
echo "$EXPLANATORY a cooperative swarm."
echo "$EXPLANATORY Hit Enter to Continue"
read
echo "$EXPLANATORY Initializing our swarm, starting with manager1"
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker swarm init --listen-addr \$(docker-machine ip manager1) --advertise-addr \$(docker-machine ip manager1)\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "docker swarm init --listen-addr $(docker-machine ip manager1) --advertise-addr $(docker-machine ip manager1)"
echo "$EXPLANATORY Swarn initialized!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Get the tokens
echo "$EXPLANATORY Getting our join tokens for workers and managers"
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker swarm join-token manager -q\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
export manager_token=`docker-machine ssh manager1 "docker swarm join-token manager -q"`
echo "manager_token: $manager_token"
echo "$EXPLANATORY Hit Enter to Continue"
read
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker swarm join-token worker -q\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
export worker_token=`docker-machine ssh manager1 "docker swarm join-token worker -q"`
echo "worker_token: $worker_token"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Add the remaining managers
echo "$EXPLANATORY Adding our other managers to the swarm, utilizing the manager token"
echo "$EXPLANATORY docker-machine ssh manager\$x \"docker swarm join --token $manager_token --listen-addr \$(docker-machine ip manager\$x) --advertise-addr \$(docker-machine ip manager\$x) \$(docker-machine ip manager1)\""
echo "$EXPLANATORY Hit Enter to Execute the Command for each Manager>=2"
read
for node in $(seq 2 $managers);
do
	echo "$EXPLANATORY manager$node joining swarm as manager ..."
	docker-machine ssh manager$node \
		"docker swarm join \
		--token $manager_token \
		--listen-addr $(docker-machine ip manager$node) \
		--advertise-addr $(docker-machine ip manager$node) \
		$(docker-machine ip manager1)"
done
echo "$EXPLANATORY Remaining managers joined the swarm!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Display the swarm
echo "$EXPLANATORY Our swarm managers are now configured, lets take a look..."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker node ls\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "docker node ls"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Add the workers
echo "$EXPLANATORY Adding our workers to the swarm, utilizing the worker token"
echo "$EXPLANATORY docker-machine ssh manager\$x \"docker swarm join --token $worker_token --listen-addr \$(docker-machine ip manager\$x) --advertise-addr \$(docker-machine ip manager\$x) \$(docker-machine ip manager1)\""
echo "$EXPLANATORY Hit Enter to Execute the Command for each Worker"
read
for node in $(seq 1 $workers);
do
	echo "$EXPLANATORY worker$node joining swarm as worker ..."
	docker-machine ssh worker$node \
	"docker swarm join \
	--token $worker_token \
	--listen-addr $(docker-machine ip worker$node) \
	--advertise-addr $(docker-machine ip worker$node) \
	$(docker-machine ip manager1):2377"
done
echo "$EXPLANATORY Workers joined the swarm!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Display the swarm
echo "$EXPLANATORY Our swarm is now configured, lets take a look..."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker node ls\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "docker node ls"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Start monitor, open in browser
echo "$EXPLANATORY This command line view of the swarm is a bit cumbersome..."
echo "$EXPLANATORY Let's configure a pretty web view on one of managers"
echo "$EXPLANATORY This will run outside of the swarm, but on one of the nodes"
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer"
echo "$EXPLANATORY Web visualizer running on manager!"
echo "$EXPLANATORY Open it in a browser at http://$(docker-machine ip manager1):8080"
echo "$EXPLANATORY If you've had the DO web page open until now"
echo "$EXPLANATORY feel free to close it, nothing else exciting is"
echo "$EXPLANATORY going to happen in it (unless you want to watch "
echo "$EXPLANATORY cleanup at the very end)"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Bootstrap registry
echo "$EXPLANATORY Docker swarms require a registry accessible to all the nodes"
echo "$EXPLANATORY to pull container images from, we could use the dockerhub for "
echo "$EXPLANATORY this, but what if we want our images to stay private?"
echo "$EXPLANATORY Lets bootstrap our own registry into the swarm itself, for "
echo "$EXPLANATORY the swarm to use to centralize its own images outside of the "
echo "$EXPLANATORY dockerhub"
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker service create --name registry --publish 5000:5000 registry:2\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "docker service create --name registry --publish 5000:5000 registry:2"
echo "$EXPLANATORY Internal registry running!"
echo "$EXPLANATORY Our swarm is now hosting it's own registry. Take a look in "
echo "$EXPLANATORY the swarm web visualizer to see where it's running."
echo "$EXPLANATORY The swarm load balancer does a cool trick where _any_ node"
echo "$EXPLANATORY can be connected to on the port a service advertises and the"
echo "$EXPLANATORY client will be connected to the node running it."
echo "$EXPLANATORY Thus, connecting to localhost:5000 on _any_ node will connect"
echo "$EXPLANATORY us to the internal registry"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Load balancing demo
echo "$EXPLANATORY Let's try out this load balancing/dynamic addressing."
echo "$EXPLANATORY Note the node that the registry is running on."
echo "$EXPLANATORY First, lets query the registry API on manager1"
echo "$EXPLANATORY $ curl $(docker-machine ip manager1):5000/v2/_catalog"
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
curl $(docker-machine ip manager1):5000/v2/_catalog
echo "$EXPLANATORY Hit Enter to Continue"
read
echo "$EXPLANATORY Now lets try the same thing, but on worker1"
echo "$EXPLANATORY $ curl $(docker-machine ip worker1):5000/v2/_catalog"
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
curl $(docker-machine ip worker1):5000/v2/_catalog
echo "$EXPLANATORY Hit Enter to Continue"
read
echo "$EXPLANATORY The same result! Whether it was running on the host"
echo "$EXPLANATORY we referenced or not!"
echo "$EXPLANATORY Hit Enter to Continue"
read
echo "$EXPLANATORY Importantly, this also works internally, for example..."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"curl 127.0.0.1:5000/v2/_catalog\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "curl 127.0.0.1:5000/v2/_catalog"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Clone the git repo onto a manager
echo "$EXPLANATORY Our swarm is now configured and bootstrapped. Let's configure "
echo "$EXPLANATORY the repository services themselves."
echo "$EXPLANATORY Hit Enter to Continue"
read
echo "$EXPLANATORY Step one is fairly standard, let's clone the git orchestration "
echo "$EXPLANATORY repository for the project."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"git clone https://github.com/bnbalsamo/microservice_repository_orchestration.git\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "git clone https://github.com/bnbalsamo/microservice_repository_orchestration.git"
echo "$EXPLANATORY Orchestration repository cloned!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Download orchestration repo requirements
echo "$EXPLANATORY The docker build process also requires docker-compose."
echo "$EXPLANATORY We need to grab the containized image of docker-compose "
echo "$EXPLANATORY to use for our builds"
echo "$EXPLANATORY $ docker-machine ssh manager1 \"cd microservice_repository_orchestration && curl -L --fail https://github.com/docker/compose/releases/download/1.13.0/run.sh > docker-compose && chmod +x docker-compose\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "cd microservice_repository_orchestration/ && curl -L --fail https://github.com/docker/compose/releases/download/1.13.0/run.sh > docker-compose && chmod +x docker-compose"
echo "$EXPLANATORY docker-compose installed!"
echo "$EXPLANATORY Hit Enter to Continue"
read
echo "$EXPLANATORY Our builds also require envsubst, a command provided by the gettext package of GNU utilities, so lets grab that as well."
echo "$EXPLANATORY docker-machine ssh manager1 \"tce-load -wi gettext.tcz\""
echo "$EXPLANATORY Hit Enter to Continue"
read
docker-machine ssh manager1 "tce-load -wi gettext.tcz"
echo "$EXPLANATORY gettext installed!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Repo clone script
echo "$EXPLANATORY Now that our requirements are sorted out, lets utilize "
echo "$EXPLANATORY our orchestration tools, cloning all of the microservice "
echo "$EXPLANATORY repositories into our local environment."
echo "$EXPLANATORY Fun fact: All of the microservices are independent "
echo "$EXPLANATORY projects, and can be run standalone or in any number "
echo "$EXPLANATORY of other configurations, if required."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"cd microservice_repository_orchestration && sh clone_repos.sh\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "cd microservice_repository_orchestration && sh clone_repos.sh"
echo "$EXPLANATORY Microservice repositories cloned!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Alter config file
echo "$EXPLANATORY All of the configuration for the microservices is "
echo "$EXPLANATORY handled via environmental variables, installing "
echo "$EXPLANATORY the environmental variables in the containers is "
echo "$EXPLANATORY handled by the docker build tools. The configuration "
echo "$EXPLANATORY for the docker build tools is handled by host "
echo "$EXPLANATORY environmental variables."
echo "$EXPLANATORY Concisely, at build time we have the ability to "
echo "$EXPLANATORY configure _all_ variables at build time in one place, "
echo "$EXPLANATORY vars.env in the orchestration repository."
echo "$EXPLANATORY We need to make one change here, specifying the hostname "
echo "$EXPLANATORY the repository will be visible at. I'll do this with "
echo "$EXPLANATORY sed, but it is perfectly reasonable to do with an editor "
echo "$EXPLANATORY manually before build time."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"cd microservice_repository_orchestration && mv vars.env vars.env.old && cat vars.env.old | sed 's/SWARM_HOST=.*$/SWARM_HOST=http:\/\/\$(docker-machine ip manager1)/' > vars.env\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "cd microservice_repository_orchestration && mv vars.env vars.env.old && cat vars.env.old | sed 's/SWARM_HOST=.*$/SWARM_HOST=http:\/\/$(docker-machine ip manager1)/' > vars.env"
echo "$EXPLANATORY vars.env configured for manager1 ip!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Build yml
echo "$EXPLANATORY With our configuration set, we can now build the yml"
echo "$EXPLANATORY file which drives the docker build process."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"cd microservice_repository_orchestration && sh build_swarm_yml.sh\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "cd microservice_repository_orchestration && sh build_swarm_yml.sh"
echo "$EXPLANATORY swarm_stack.yml built!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Build Images
echo "$EXPLANATORY With our docker orchestration configured, we can now "
echo "$EXPLANATORY utilize the docker build tools to complete our setup. "
echo "$EXPLANATORY Lets build our service images."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml build\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml build"
echo "$EXPLANATORY Service images built!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Push
echo "$EXPLANATORY With our images built, we need to push them to the "
echo "$EXPLANATORY swarm registry so they are accessible to all nodes."
echo "$EXPLANATORY $ docker-machine ssh manager1 \"cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml push\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "cd microservice_repository_orchestration && ./docker-compose -f swarm_stack.yml push"
echo "$EXPLANATORY Service images pushed to the registry!"
echo "$EXPLANATORY Hit Enter to Continue"
read


# Deploy
echo "$EXPLANATORY Our images have now been pushed to the swarm registry "
echo "$EXPLANATORY and our ready to be run by our nodes. Let's roll out "
echo "$EXPLANATORY our repository swarm!"
echo "$EXPLANATORY $ docker-machine ssh manager1 \"cd microservice_repository_orchestration && docker stack deploy --compose-file swarm_stack.yml repository_swarm\""
echo "$EXPLANATORY Hit Enter to Execute the Command"
read
docker-machine ssh manager1 "cd microservice_repository_orchestration && docker stack deploy --compose-file swarm_stack.yml repository_swarm"
echo "$EXPLANATORY Services deployed!"
echo "$EXPLANATORY Interface should now be available at http://$(docker-machine ip manager1)"
echo "$EXPLANATORY Feel free to click around and test creating a collection,"
echo "$EXPLANATORY running the accutil against the URLs, etc"
echo "$EXPLANATORY Hit Enter to Continue"
read


# TODO: service/VM scaling demo
# Create another VM
# add new VM to swarm dynamically
# get scalable service identifiers
# scale services
# remove a VM, watch services move


# Cleanup
echo "$EXPLANATORY Tada! A microservice based repository running"
echo "$EXPLANATORY in a docker swarm."
echo "$EXPLANATORY to leave the swarm intact, and just remove the"
echo "$EXPLANATORY repository swarm services you can run:"
echo "$EXPLANATORY $ docker-machine ssh manager1 \"docker stack rm repository_swarm\""
echo "$EXPLANATORY To remove the virtual machines (and the swarm) "
echo "$EXPLANATORY entirely you can run:"
echo "$EXPLANATORY $ docker-machine rm manager{1..$managers} worker{1..$workers}"
echo "$EXPLANATORY This completes the microservice repository demo!"
