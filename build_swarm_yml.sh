#!/bin/sh
set -a
. swarm_env_vars.env
envsubst < swarm_stack.template > swarm_stack.yml
