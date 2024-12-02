#! /bin/bash

if [ ! "$(which gotestsum)" ]; then
  echo The gotestsum command is not available in this executor.
  exit 1
fi

if [ -n "${ORB_EVAL_PROJECT_PATH}" ]; then
  cd "${ORB_EVAL_PROJECT_PATH}" || exit
fi

if [ -n "$ORB_VAL_PACKAGES" ];then
  set -- "$@" --packages "${ORB_VAL_PACKAGES}"
fi

if [ -n "$ORB_VAL_JUNITFILE" ];then
  set -- "$@" --junitfile "${ORB_VAL_JUNITFILE}"
fi

if [ -n "$ORB_VAL_COVERMODE" ];then
  COVERMODE="-covermode=${ORB_VAL_COVERMODE}"
fi

if [ -n "$ORB_EVAL_COVER_PROFILE" ];then
  INPUT_COVER_PROFILE=$(eval echo "$ORB_EVAL_COVER_PROFILE")
  COVER_PROFILE="-coverprofile=${INPUT_COVER_PROFILE}"
fi

set -x
gotestsum \
  "$@" \
  -- \
  "${COVERMODE}" \
  "${COVER_PROFILE}" \
  -coverpkg="$ORB_VAL_PACKAGES"
set +x
