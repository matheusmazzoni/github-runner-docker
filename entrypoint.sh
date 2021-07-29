#!/usr/bin/env bash

set -e
if [[ -z ${GH_RUNNER_NAME} ]];
then
    echo "Environment variable 'GH_RUNNER_NAME' is not set"
    exit 1
fi

if [[ -z ${GH_RUNNER_TOKEN} ]];
then
    echo "Environment variable 'GH_RUNNER_TOKEN' is not set"
    exit 1
fi

if [[ -z ${GH_REPOSITORY} ]];
then
    echo "Environment variable 'GH_REPOSITORY' is not set"
    exit 1
fi

echo "Github Runner Configs:"
echo "  L Version: $(./config.sh --version)"
echo "  L Commit: $(./config.sh --commit)"

workDir=/tmp/_work/$(pwgen -s1 10)
mkdir -p ${workDir}
echo "Runner working directory: ${workDir}"

/runner/config.sh --unattended --name ${GH_RUNNER_NAME} --url ${GH_REPOSITORY} --token ${GH_RUNNER_TOKEN} --labels ${GH_RUNNER_LABELS} --replace --work ${workDir} || echo

exec /runner/run.sh