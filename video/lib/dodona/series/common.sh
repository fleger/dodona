#! /bin/bash

# ASCII QuickSort (removes repeated values)
dodona.user.series.quicksort() {
  local -a array=("$@")
  local -a l=()
  local -a g=()
  local pivot
  local x
  if [ ${#array[@]} -lt 2 ]; then
    echo "${array[@]}"
  else
    pivot="${array[0]}"
    for x in "${array[@]}"; do
      if [[ "x$pivot" > "x$x" ]]; then
        l=("${l[@]}" "$x")
      elif [[ "x$pivot" < "x$x" ]]; then
        g=("${g[@]}" "$x")
      fi
    done
    echo $(dodona.user.series.quicksort "${l[@]}") $pivot $(dodona.user.series.quicksort "${g[@]}")
  fi
}

# Recursive persistant state writer
dodona.user.series.writeStates() {
  if [ "x$1" = "x/" ] || [ "x$1" = "x." ] || [ "x$1" = "x$2" ]; then
    return
  else
    echo "$(basename $1)" > "$(dirname $1)/$D_SERIES_PERSIST"
    dodona.user.series.writeStates "$(dirname $1)" "$2"
  fi
}

# Set up some variables and constants
dodona.user.preFinal() {
  shopt -s nullglob
  readonly D_SERIES_PERSIST=".state"
  readonly D_SERIES_ARCHIVE="$HOME/media/data/triage/video/archive"
  D_SERIES_VIDEO_PATTERNS=('*.avi' '*.divx' '*.mkv' '*.mp4' '*.flv' '*.wmv' '*.mpg' '*.mpeg' '*.ogm')
  readonly D_SERIES_SCORE_EXHAUSTED=0
  readonly D_SERIES_SCORE_NEXTFILE=1

  readonly D_SERIES_SCORE_NEXT_SEASON=2
  readonly D_SERIES_SCORE_CURRENT_SEASON=4

  D_SERIES_CHOICE_STACK=("")
  D_SERIES_SCORE_STACK=(1)
}

dodona.user.postFinal() {
  if [[ -f "${D_SERIES_CHOICE_STACK[0]}" ]]; then
    echo "Playing ${D_SERIES_CHOICE_STACK[0]} (score: ${D_SERIES_SCORE_STACK[0]})" &&
    mplayer -use-filedir-conf "${D_SERIES_CHOICE_STACK[0]}" &&
    mv "${D_SERIES_CHOICE_STACK[0]%.*}"* "$D_SERIES_ARCHIVE" && 
    dodona.user.series.writeStates "${D_SERIES_CHOICE_STACK[0]}"  "$1"
  else
    echo "'${D_SERIES_CHOICE_STACK[0]}' is not a file."
  fi
}
