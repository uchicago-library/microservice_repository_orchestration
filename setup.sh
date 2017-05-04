#! /bin/bash


DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/.env
export UNIFIER_EXTERNAL_PORT UNIFIER_INTERNAL_PORT ARCHSTOR_INTERNAL_PORT QREMIS_API_INTERNAL_PORT ACC_IDNEST_INTERNAL_PORT DEAD_SIMPLE_INTERFACE_INTERNAL_PORT UNIFIER_HOST

for x in $DIR/configs/*; do envsubst < $x > `echo $x | rev | cut -c 10- | rev`.py; done
git clone https://github.com/bnbalsamo/archstor.git && \
    cp ./configs/archstor_conf.py archstor/config.py
git clone https://github.com/uchicago-library/idnest.git && \
    cp ./configs/acc_idnest_conf.py idnest/config.py
git clone https://github.com/bnbalsamo/qremis_api.git && \
    cp ./configs/qremis_api_conf.py qremis_api/config.py
git clone https://github.com/bnbalsamo/microservice_repository_dead_simple_interface.git && \
    cp ./configs/dead_simple_interface_conf.py microservice_repository_dead_simple_interface/config.py
git clone https://github.com/bnbalsamo/demo_records_api.git && \
    cp ./configs/demo_records_api_conf.py demo_records_api/config.py
for x in $DIR/configs/*.template; do rm `echo $x | rev | cut -c 10- | rev`.py; done
