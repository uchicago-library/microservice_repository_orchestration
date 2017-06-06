This repository contains the necessary files to spin up the core microservices for an archival digital repository.

These microservices are still in varying stages of development, changes may occur without warning.

It relies on the following projects:

- [archstor](https://github.com/bnbalsamo/archstor) for data storage
- [idnest](https://github.com/uchicago-library/idnest) for basic accession organization
- [qremis_api](https://github.com/bnbalsamo/qremis_api) for managing metadata records
- [demo_records_api](https://github.com/bnbalsamo/demo_records_api) a quick simple accession/collection records management API
- [microservice_repository_dead_simple_interface](https://github.com/bnbalsamo/microservice_repository_dead_simple_interface) An HTTP interface to wrap the API functionalities.

The [accutil](https://github.com/bnbalsamo/qremis_accutil) is built to ingest files into the microservice systems.

# Swarm Setup Instructions
## Prerequisites/Notes
- This assumes you have your swarm configured, and are ssh'd into a manager node to run commands from. A basic tutorial utilizing docker-machine can be found [here](https://docs.docker.com/engine/swarm/swarm-tutorial/create-swarm/)
- Configuration relies on the envsubst command, part of the gettext package. It must be installed on your manager node (or where ever you're building from) To do this in boot2docker: tce-load -wi gettext.tcz
- Setup also requires docker-compose, installation instructions for various platforms [here](https://docs.docker.com/compose/install/)
    - If using a docker-machine swarm the sudo -i edge case is required.

0. Optional: Configure Swarm Visualizer
If you'd like to have the swarm visualizer
for pretty graphics running at $SWARM_HOST:8080
```
$ docker run -it -d -p 8080:8080 -v /var/run/docker.sock:/var/run/docker.sock dockersamples/visualizer
```

1. Configure the Registry
Manually fire up a docker image registry. If you already have a registry,
instead set the $REGISTRY environmental variable.
```
$ docker service create --name registry --publish 5000:5000 registry:2
```

2. Clone the Git Repository
```
$ git clone https://github.com/bnbalsamo/microservice_repository_orchestration.git
```

3. Navigate into the Repository Root
```
$ cd microservice_repository_orchestration
```

4. Clone the Other Relevant Git Repositories
```
$ ./clone_repos.sh
```

5. Edit Settings in the swarm_env_vars.env File
**!! NOTE: These files are going to get sourced in later scripts. !!**
Use whatever editor you like, the files are plaintext. Nano example provided:
```
$ nano swarm_env_vars.env
```

6. Build/Insert the Configuration Files
```
$ ./build_swarm_configs.sh
```

7. Build the YML for Docker Compose
```
$ ./build_swarm_yml.sh
```

8. Build the Container Images
```
$ docker-compose -f swarm_stack.yml build
```

9. Push the Built Images to the Docker Repository
```
$ docker-compose -f swarm_stack.yml push
```

10. Deploy the Services to the Swarm
```
$ docker stack deploy --compose-file swarm_stack.yml repository_swarm
```
You should now be able to navigate to $SWARM_HOST and see the interface

# Compose Setup Instructions
## Prerequisites/Notes
- If your sh doesn't support source you may have to run the sh scripts with bash manually
- Configuration relies on the envsubst command, part of the gettext package. It must be installed on your manager node (or where-ever you're building from) To do this in boot2docker: tce-load -wi gettext.tcz
- Setup also requires docker-compose, installation instructions for various platforms [here](https://docs.docker.com/compose/install/)

1. Clone the Git Repository
```
$ git clone https://github.com/bnbalsamo/microservice_repository_orchestration.git
```

2. Navigate into the Repository Root
```
$ cd microservice_repository_orchestration
```

3. Clone the Other Relevant Git Repositories
```
$ ./clone_repos.sh
```

4. Edit Settings in the compose_env_vars.env File
**!! NOTE: These files are going to get sourced in later scripts. !!**
Use whatever editor you like, the files are plaintext. Nano example provided:
```
$ nano compose_env_vars.env
```

5. Build/Insert the Configuration Files
```
$ ./build_compose_configs.sh
```

6. Build the YML for Docker Compose
```
$ ./build_compose_yml.sh
```

7. Build the Container Images
```
$ docker-compose -f docker-compose.yml build
```

8. Start the containers
```
$ docker-compose -f docker-compose.yml up
```
You should now be able to navigate to $UNIFIER_HOST:$UNIFIER_EXTERNAL_PORT
and see the interface 
