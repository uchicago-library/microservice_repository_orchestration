#!/bin/sh
set -a
. compose_env_vars.env
envsubst < compose.template > docker-compose.yml
