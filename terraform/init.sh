#!/bin/bash

script=$(realpath -s "$0")
scriptpath=$(dirname "$script")

cp -u -p $scriptpath/envs/default/all.env.default $scriptpath/envs/prod/all.env
cp -u -p $scriptpath/envs/default/common.env.default $scriptpath/envs/prod/common.env
cp -u -p $scriptpath/envs/default/staging.env.default $scriptpath/envs/prod/staging.env
cp -u -p $scriptpath/envs/default/test.env.default $scriptpath/envs/prod/test.env

cp -u -p $scriptpath/configs/cloud-config.default $scriptpath/configs/cloud-config
