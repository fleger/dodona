#! /bin/bash

readonly dodona_SCRIPT=".dodona"
readonly -a dodona_ARGS=("$@")

dodona.isDodonaDir() {
  [ -f "$1/$dodona_SCRIPT" ]
}

dodona.loadDir() {
  if dodona.isDodonaDir "$1"; then
    #echo "loadDir $1"
    . "$1/$dodona_SCRIPT"
    $2 && dodona.user.preFinal "$1"
    dodona.user.preChildren "$1"
    local _oldIFS="$IFS"
    IFS=$'\n'
    local d
    # Find all folders
    for d in $(find "$1" -mindepth 1 -maxdepth 1 -type d -regex "^$1/[^.].+" -print | sort); do
      IFS="$_oldIFS"
      if dodona.isDodonaDir "$d"; then
        dodona.user.preChild "$1"
        dodona.loadDir "$d" false
        . "$1/$dodona_SCRIPT"
        dodona.user.postChild "$1"
      fi
      IFS=$'\n'
    done
    IFS="$_oldIFS"
    dodona.user.postChildren "$1"
    $2 && dodona.user.postFinal "$1"
  else
    $2 && echo "Not a dodona directory." && return 1
  fi
}

dodona.loadDir "$PWD" true
