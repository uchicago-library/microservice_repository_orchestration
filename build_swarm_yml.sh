#!/bin/sh
set -a
. vars.env
envsubst < swarm_stack.template > swarm_stack.yml
