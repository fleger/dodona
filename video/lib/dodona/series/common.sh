#! /bin/bash

dodona.user.series.writeStates() {
  if [ "$1" = "/" ] || [ "$1" = "." ] || [ "$1" = "$2" ]; then
    return
  else
    echo """$(basename "$1")""" > """$(dirname "$1")/$D_SERIES_PERSIST"""
    dodona.user.series.writeStates """$(dirname "$1")""" "$2"
  fi
}

dodona.user.preFinal() {
  shopt -s extglob
  
  readonly D_SERIES_PERSIST=".state"
  readonly D_SERIES_ARCHIVE="$HOME/media/data/triage/video/archive"
  
  readonly D_SERIES_SCORE_EXHAUSTED=0
  readonly D_SERIES_SCORE_NEXTFILE=1
  
  readonly D_SERIES_SCORE_NEXT_SEASON=2
  readonly D_SERIES_SCORE_CURRENT_SEASON=4
  
  D_SERIES_CHOICE_STACK=("")
  D_SERIES_SCORE_STACK=(1)
}

dodona.user.postFinal() {
  if [[ -f "${D_SERIES_CHOICE_STACK[0]}" ]]; then
    dodona.user.series.writeStates "${D_SERIES_CHOICE_STACK[0]}"  "$1" &&
    echo "Playing ${D_SERIES_CHOICE_STACK[0]} (score: ${D_SERIES_SCORE_STACK[0]})" &&
    mplayer -use-filedir-conf "${D_SERIES_CHOICE_STACK[0]}" &&
    mv "${D_SERIES_CHOICE_STACK[0]%.*}"* "$D_SERIES_ARCHIVE"
  else
    echo "${D_SERIES_CHOICE_STACK[0]} is not a file."
  fi
}
