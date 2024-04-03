#!/bin/bash

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null 2>&1 && pwd)"

# переход в директорию где лежит скрипт
cd $DIR

if [ $# -gt 0 ]; then

    # test, staging, ...
    ANSIBLE_ENV=$1

    shift 1

    ANSIBLE_PARAMS=$@

    if [ -z $TF_ENV ]; then
        echo >&2 "$TF_ENV required..."
        exit 1
    fi

    if [ ! -d "./inventory/$ANSIBLE_ENV" ]; then
        echo >&2 "Directory $DIR/$ANSIBLE_ENV" does not exist...
        exit 1
    fi

    ls ./envs/prod/env_ansible_all.env >/dev/null && source ./envs/prod/env_ansible_all.env
    ls ./envs/prod/env_ansible_${ANSIBLE_ENV}.env >/dev/null && source ./envs/prod/env_ansible_${ANSIBLE_ENV}.env

    ansible-playbook -u $SSH_USER ./playbooks/$ANSIBLE_ENV.yaml $ANSIBLE_PARAMS

fi

# возвращение в директорию из которой вызывался скрипт
cd -
