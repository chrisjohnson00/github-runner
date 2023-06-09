#!/bin/bash

ORGANIZATION=$ORGANIZATION
REPO=$REPO
ACCESS_TOKEN=$ACCESS_TOKEN
LABELS=$LABELS
$RUNNER_NAME=$RUNNER_NAME

REG_TOKEN=$(curl -sX POST -H "Authorization: Bearer ${ACCESS_TOKEN}" https://api.github.com/repos/${ORGANIZATION}/${REPO}/actions/runners/registration-token | jq .token --raw-output)

cd /home/docker/actions-runner

./config.sh --url https://github.com/${ORGANIZATION}/${REPO} --token ${REG_TOKEN} --unattended --labels ${LABELS} --name ${RUNNER_NAME}

cleanup() {
    echo "Removing runner..."
    ./config.sh remove --unattended --token ${REG_TOKEN}
}

trap 'cleanup; exit 130' INT
trap 'cleanup; exit 143' TERM

./run.sh & wait $!
