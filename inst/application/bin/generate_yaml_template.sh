#!/bin/bash

# Get the path to the installed R package
PACKAGE_PATH=$(Rscript --vanilla -e "cat(system.file(package = 'prolfquapp'))")

# Build the path to the R script
R_SCRIPT_PATH="${PACKAGE_PATH}/application/generate_templates.R"

# Check if the R script exists
if [[ -f "$R_SCRIPT_PATH" ]]; then
    Rscript --vanilla "$R_SCRIPT_PATH" "$@"
else
    echo "Error: R script not found at '$R_SCRIPT_PATH'"
    exit 1
fi