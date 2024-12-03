#!/usr/bin/env bash
if [ "${ORB_VAL_PARALLEL}" = "m" ] || [ "${ORB_VAL_PARALLEL_TESTS}" = "m" ]; then
  GOMAXPROCS=$(go run max_parallelism/main.go)
fi

if [ "${ORB_VAL_PARALLEL}" = "m" ]; then
  ORB_VAL_PARALLEL=$GOMAXPROCS
fi

if [ "${ORB_VAL_PARALLEL_TESTS}" = "m" ]; then
  ORB_VAL_PARALLEL_TESTS=$GOMAXPROCS
fi

if [ -n "${ORB_EVAL_PROJECT_PATH}" ]; then
  cd "${ORB_EVAL_PROJECT_PATH}" || exit
fi

COVER_PROFILE=$(eval echo "$ORB_EVAL_COVER_PROFILE")

if [ -n "$ORB_VAL_RACE" ]; then
  set -- "$@" -race
  ORB_VAL_COVER_MODE=atomic
fi

if [ "$ORB_VAL_FAILFAST" != "false" ]; then
  set -- "$@" -failfast
fi

if [ -n "$ORB_VAL_SHORT" ]; then
  set -- "$@" -short
fi

if [ -n "$ORB_VAL_VERBOSE" ]; then
  set -- "$@" -v
fi

set -x
go test -count="$ORB_VAL_COUNT" -p "${ORB_VAL_PARALLEL}" \
    -parallel "${ORB_VAL_PARALLEL_TESTS}" \
    -coverprofile="$COVER_PROFILE" -covermode="$ORB_VAL_COVER_MODE" \
    "$ORB_VAL_PACKAGES" -coverpkg="$ORB_VAL_PACKAGES" \
    -timeout="$ORB_VAL_TIMEOUT" \
    "$@"
set +x
