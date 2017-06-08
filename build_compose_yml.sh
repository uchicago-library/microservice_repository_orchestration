#!/bin/sh
set -a
. vars.env
envsubst < compose.template > docker-compose.yml
