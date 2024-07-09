#!/bin/bash

script=$(realpath -s "$0")
scriptpath=$(dirname "$script")

cp -u -p $scriptpath/envs/default/env_tf_all.env.default $scriptpath/envs/prod/env_tf_all.env
cp -u -p $scriptpath/secrets/default/yc_key_secret.default $scriptpath/secrets/prod/yc_key_secret
cp -u -p $scriptpath/cloud/default/cloud-config.default $scriptpath/cloud/prod/cloud-config
