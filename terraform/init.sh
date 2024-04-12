#!/bin/bash

script=$(realpath -s "$0")
scriptpath=$(dirname "$script")

cp -u -p $scriptpath/envs/default/env_tf_all.env.default $scriptpath/envs/prod/env_tf_all.env
cp -u -p $scriptpath/envs/default/env_tf_common.env.default $scriptpath/envs/prod/env_tf_common.env
cp -u -p $scriptpath/envs/default/env_tf_dev.env.default $scriptpath/envs/prod/env_tf_dev.env
cp -u -p $scriptpath/envs/default/env_tf_test.env.default $scriptpath/envs/prod/env_tf_test.env
cp -u -p $scriptpath/envs/default/env_tf_staging.env.default $scriptpath/envs/prod/env_tf_staging.env

cp -u -p $scriptpath/secrets/default/yc_key_secret_file.default $scriptpath/secrets/default/yc_key_secret_file

cp -u -p $scriptpath/configs/cloud-config.default $scriptpath/configs/cloud-config
