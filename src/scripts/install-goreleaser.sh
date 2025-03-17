#!/bin/bash

GO_STR_VERSION="$(echo "${GO_STR_VERSION}"| circleci env subst)"

go install github.com/goreleaser/goreleaser/v2@"${GO_STR_VERSION}"
goreleaser --version
