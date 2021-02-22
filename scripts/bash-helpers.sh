#!/usr/bin/env bash

error() {
    echo -e "ERROR: $*" >&2
    exit 1
}

run_step() {
  echo -e ""
  echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo -e "RUN STEP: $@"
  echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  "$@" || error "failed RUN STEP $@ with code $?"
  echo -e ""
  echo -e ":) completed RUN STEP $@ with code $?"
  echo -e ""
}

skip_step() {
  echo -e ""
  echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo -e "SKIP STEP: $@"
  echo -e "~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~"
  echo -e ""
}
