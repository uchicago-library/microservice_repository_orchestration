This repository contains the necessary files to spin up the core microservices for an archival digital repository.

These microservices are still in varying stages of development, changes my occur without warning.

It relies on the following projects:

- [archstor](https://github.com/bnbalsamo/archstor) for data storage
- [idnest](https://github.com/uchicago-library/idnest) for basic accession organization
- [qremis_api](https://github.com/bnbalsamo/qremis_api) for managing metadata records
- [demo_records_api](https://github.com/bnbalsamo/demo_records_api) a quick simple accession/collection records management API
- [microservice_repository_dead_simple_interface](https://github.com/bnbalsamo/microservice_repository_dead_simple_interface) An HTTP interface to wrap the API functionalities.

The [accutil](https://github.com/bnbalsamo/qremis_accutil) is built to ingest files into the microservice systems.

# Swarm setup instructions
```
# This assumes you have your swarm configured,
# and are ssh'd into a manager node to run
# commands from. Configuration relies on the
# envsubst command, part of the gettext package.
# It must be installed on your manager node
# (or where-ever you're building from)

# If you'd like to have the swarm visualizer
# for pretty graphics running at $SWARM_HOST:8080
$ docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer

# Manually fire up our registry. If you already have a registry,
# instead set the $REGISTRY environmental variable here.

$ docker service create --name registry --publish 5000:5000 registry:2

# Clone the git repo
$ git clone https://github.com/bnbalsamo/microservice_repository_orchestration.git

# cd into the repository root
$ cd microservice_repository_orchestration

# !! ALL THE FOLLOWING COMMANDS MUST BE RUN FROM THE GIT REPO ROOT !!

# Clone the relevant repos
$ ./clone_repos.sh

# Edit any relevant settinngs in the swarm_env_vars.env
# !! NOTE: These files are going to get sourced in later scripts. !!

# Build our configs and put them in place
$ ./build_swarm_configs.sh

# Build the yml for docker compose
$ ./build_swarm_yml.sh

# Build our container images
$ docker-compose -f swarm_stack.yml build

# Push the built images to the docker repository
$ docker-compose -f swarm_stack.yml push

# Deploy the services to the swarm
$ docker stack deploy --compose-file swarm_stack.yml repository_swarm

# You should now be able to navigate to $SWARM_HOST and see the interface
```
