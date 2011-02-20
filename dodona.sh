#! /bin/bash

readonly dodona_SCRIPT=".dodona"

dodona_working_dir="$1"
: ${dodona_working_dir:=$PWD}

dodona.loadDir() {
  if [ -f "$1/$dodona_SCRIPT" ]; then
    #echo "loadDir $1"
    . "$dodona_SCRIPT"
    $2 && dodona.user.preFinal "$1"
    dodona.user.preChildren "$1"
    local _oldIFS="$IFS"
    IFS=$'\n'
    local d
    for d in $(find "$1" -mindepth 1 -maxdepth 1 -type d -regex "^$1/[^.].+" -print | sort); do
      IFS="$_oldIFS"
      dodona.user.preChild "$1"
      dodona.loadDir "$d" false
      . "$1/$dodona_SCRIPT"
      dodona.user.postChild "$1"
    done
    dodona.user.postChildren "$1"
    $2 && dodona.user.postFinal "$1"
  else
    $2 && echo "Not a dodona directory."
  fi
}

dodona.loadDir "$dodona_working_dir" true
