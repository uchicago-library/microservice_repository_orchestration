#! /bin/bash

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source $DIR/.env
for x in $DIR/configs/*; do envsubst < $x > `echo $x | rev | cut -c 10- | rev`.py; done
git clone https://github.com/bnbalsamo/archstor.git && \
    cp ./configs/archstor_conf.py archstor/config.py
git clone https://github.com/uchicago-library/idnest.git && \
    cp ./configs/acc_idnest_conf.py idnest/config.py
git clone https://github.com/bnbalsamo/qremis_api.git && \
    cp ./configs/qremis_api_conf.py qremis_api/config.py
for x in $DIR/configs/*.template; do rm `echo $x | rev | cut -c 10- | rev`.py; done
