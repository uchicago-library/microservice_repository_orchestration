#! /bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

# Clone the repos into this dir
# If these error because they already exist thats fine, 
# assume we just want to refresh our configs
git clone https://github.com/bnbalsamo/archstor.git
git clone https://github.com/uchicago-library/idnest.git
git clone https://github.com/bnbalsamo/qremis_api.git
git clone https://github.com/bnbalsamo/microservice_repository_dead_simple_interface.git
git clone https://github.com/bnbalsamo/demo_records_api.git

# Handle the configs
source $DIR/.env
export UNIFIER_EXTERNAL_PORT UNIFIER_INTERNAL_PORT ARCHSTOR_INTERNAL_PORT QREMIS_API_INTERNAL_PORT ACC_IDNEST_INTERNAL_PORT DEAD_SIMPLE_INTERFACE_INTERNAL_PORT UNIFIER_HOST REC_API_INTERNAL_PORT EXTERNAL_ARCHSTOR_URL EXTERNAL_QREMIS_API_URL
for x in $DIR/configs/*; do envsubst < $x > `echo $x | rev | cut -c 10- | rev`.py; done
cp ./configs/archstor_conf.py archstor/config.py
cp ./configs/qremis_api_conf.py qremis_api/config.py
cp ./configs/dead_simple_interface_conf.py microservice_repository_dead_simple_interface/config.py
cp ./configs/dead_simple_interface_conf.py microservice_repository_dead_simple_interface/config.py
cp ./configs/demo_records_api_conf.py demo_records_api/config.py
for x in $DIR/configs/*.template; do rm `echo $x | rev | cut -c 10- | rev`.py; done
