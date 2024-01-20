#!/usr/bin/env bash
COVER_PROFILE=$(eval echo "$ORB_EVAL_COVER_PROFILE")

if [ -n "$ORB_VAL_RACE" ]; then
  set -- "$@" -race
fi

if [ -n "$ORB_VAL_FAIL_FAST" ]; then
  set -- "$@" -failfast
fi

if [ -n "$ORB_VAL_SHORT" ]; then
  set -- "$@" -short
fi

if [ -n "$ORB_VAL_VERBOSE" ]; then
  set -- "$@" -v
fi

set -x
go test -count="$ORB_VAL_COUNT" -coverprofile="$COVER_PROFILE" \
    -p "$ORB_VAL_PARALLEL" -covermode="$ORB_VAL_COVER_MODE" \
    "$ORB_VAL_PACKAGES" -coverpkg="$ORB_VAL_PACKAGES" \
    -timeout="$ORB_VAL_TIMEOUT" \
    "$@"
set +x
