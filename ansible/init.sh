#!/bin/bash

script=$(realpath -s "$0")
scriptpath=$(dirname "$script")

cp -u -p $scriptpath/envs/default/env_ansible_all.env.default $scriptpath/envs/prod/env_ansible_all.env
cp -u -p $scriptpath/envs/default/env_ansible_common.env.default $scriptpath/envs/prod/env_ansible_common.env
cp -u -p $scriptpath/envs/default/env_ansible_dev.env.default $scriptpath/envs/prod/env_ansible_dev.env
cp -u -p $scriptpath/envs/default/env_ansible_test.env.default $scriptpath/envs/prod/env_ansible_test.env
cp -u -p $scriptpath/envs/default/env_ansible_staging.env.default $scriptpath/envs/prod/env_ansible_staging.env
cp -u -p $scriptpath/envs/default/env_ansible_onprem.env.default $scriptpath/envs/prod/env_ansible_onprem.env
cp -u -p $scriptpath/envs/default/env_ansible_prod.env.default $scriptpath/envs/prod/env_ansible_prod.env

cp -u -p $scriptpath/configs/cloud-config.default $scriptpath/configs/cloud-config
