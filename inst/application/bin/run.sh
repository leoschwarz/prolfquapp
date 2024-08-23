#!/usr/bin/env bash
# This script is used to run a single command in the prolfquapp docker image .
# The current directory will be mounted to /work and set as the current working directory for the command being executed.
set -euo pipefail
# TODO add docker pull logic
DOCKER_IMAGE="prolfquapp"
if [[ $# -eq 0 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: $0 <command> [args]"
    echo "Example commands: "
    # TODO update these
    echo " $0 prolfqua_yaml.sh"
    echo " $0 prolfqua_dataset.sh"
    exit 1
fi
# TODO does this forward return codes?
docker run --rm -it --entrypoint bash -v "$(pwd)":/work -w /work $DOCKER_IMAGE "$@"