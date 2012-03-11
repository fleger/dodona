#! /bin/bash

readonly dodona_SCRIPT=".dodona"
readonly -a dodona_ARGS=("$@")

dodona.isDodonaDir() {
  [ -d "$1" ] &&
  [ -f "$1/$dodona_SCRIPT" ]
}

dodona.loadDir() {
  if dodona.isDodonaDir "$1"; then
    #echo "loadDir $1"
    . "$1/$dodona_SCRIPT"
    $2 && dodona.user.preFinal "$1"
    dodona.user.preChildren "$1"
    local d
    # Find all folders
    for d in "$1"/*; do
      if dodona.isDodonaDir "$d"; then
        dodona.user.preChild "$1"
        dodona.loadDir "$d" false
        . "$1/$dodona_SCRIPT"
        dodona.user.postChild "$1"
      fi
    done
    dodona.user.postChildren "$1"
    $2 && dodona.user.postFinal "$1"
  else
    $2 && echo "Not a dodona directory." && return 1
  fi
}

dodona.loadDir "$PWD" true
