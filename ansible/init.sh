#!/bin/bash

script=$(realpath -s "$0")
scriptpath=$(dirname "$script")

cp -u -p $scriptpath/envs/default/env_ansible_all.env.default $scriptpath/envs/prod/env_ansible_all.env
