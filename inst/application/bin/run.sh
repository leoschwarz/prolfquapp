#!/usr/bin/env bash
# This script is used to run a single command in the prolfquapp docker image.
# - The docker image is pulled if it does not exist locally.
# - The current directory will be mounted to /work and set as the current working directory for the command being executed.
set -euo pipefail
DOCKER="docker"
DOCKER_IMAGE=docker.io/leoschwarz/prolfquapp:0.0.1

if ! $DOCKER image inspect "$DOCKER_IMAGE" >/dev/null 2>&1; then
  echo "Image $DOCKER_IMAGE not found locally. Pulling..."
  $DOCKER pull "$DOCKER_IMAGE"
else
  echo "Image $DOCKER_IMAGE already exists locally."
  echo "If you want to update the image to the latest version, run the following command:"
  echo "$DOCKER pull \"$DOCKER_IMAGE\""
fi
if [[ $# -eq 0 ]] || [[ $1 == "-h" ]] || [[ $1 == "--help" ]]; then
    echo "Usage: $0 <command> [args]"
    echo "Example commands: "
    echo " $0 prolfqua_yaml.sh"
    echo " $0 prolfqua_dataset.sh"
    echo " (see README.md for more details)"
    exit 1
fi
$DOCKER run  \
  --user="$(id -u):$(id -g)" \
  --rm -it --mount type=bind,source="$(pwd)",target=/work \
  -w /work $DOCKER_IMAGE "$@"
