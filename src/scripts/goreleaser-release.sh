#!/bin/bash

GITHUB_TOKEN="$(echo "\$$GITHUB_TOKEN" | circleci env subst)"
GO_EVAL_PROJECT_PATH="$(eval echo "${GO_EVAL_PROJECT_PATH}")"

# Change to directory containing project files
cd "${GO_EVAL_PROJECT_PATH}" || return

if [ -z "${GITHUB_TOKEN}" ]; then
    echo "No GitHub Token provided. Please add token as environment variable in CircleCI."
    exit 1
fi

if [ "$GO_BOOL_VALIDATE_YAML" -eq 1 ]; then 
    # Validate .goreleaser.yaml file
    goreleaser check
fi

if [ "$GO_BOOL_PUBLISH_RELEASE" -eq 1 ]; then 
    # Build binaries and publish release to GitHub
    goreleaser release 
else
    # Build binaries and test release locally
    goreleaser release --snapshot --clean
fi


