#!/bin/bash

function install {
    ansible-galaxy install -r requirements.yml --roles-path roles
}

function help {
    echo "$0 <task> <args>"
    echo "Tasks:"
    compgen -A function | cat -n
}

TIMEFORMAT="Task completed in %3lR"
time ${@:-help}