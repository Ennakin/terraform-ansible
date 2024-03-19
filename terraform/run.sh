#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# переход в директорию где лежит скрипт
cd $DIR

if [ $# -gt 0 ]; then

    # test, staging, ...
    TF_ENV=$1

    # network, compute, ...
    TF_STATE=$2

    # init, plan, apply, destroy, ...
    TF_OPERATION=$3

    shift 3

    TF_PARAMS=$@

    echo $TF_PARAMS

    if [ ! -d "./environments/$TF_ENV/$TF_STATE" ]; then
        echo >&2 "Directory $DIR/$TF_ENV/$TF_STATE" does not exist...
        exit 1
    fi

    if [ "$TF_OPERATION" == "init" ]; then

        ls ./envs/prod/all.env >/dev/null && source ./envs/prod/all.env
        ls ./envs/prod/$TF_ENV.env >/dev/null && source ./envs/prod/$TF_ENV.env

        terraform -chdir="./environments/$TF_ENV/$TF_STATE" init \
            -backend-config=address=$TV_VAR_address/$TF_ENV-$TF_STATE \
            -backend-config=lock_address=${TV_VAR_address}/$TF_ENV-$TF_STATE/lock \
            -backend-config=unlock_address=${TV_VAR_address}/$TF_ENV-$TF_STATE/lock \
            -backend-config=username=${TV_VAR_username} \
            -backend-config=password=${TV_VAR_password} \
            -backend-config=lock_method=POST \
            -backend-config=unlock_method=DELETE \
            -backend-config=retry_wait_min=5 \
            $TF_PARAMS

    else
        ls ./envs/prod/all.env >/dev/null && source ./envs/prod/all.env
        ls ./envs/prod/$TF_ENV.env >/dev/null && source ./envs/prod/$TF_ENV.env

        terraform -chdir="./environments/$TF_ENV/$TF_STATE" "$TF_OPERATION" \
            $TF_PARAMS
    fi
fi

# возвращение в директорию из которой вызывался скрипт
cd -
