#! /bin/bash

# Helper functions

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

# Get autocrop parameters
dodona.user.series.getCropParam() {
  local totalLoops=10
  local i
  local timeStep=30
  local frames=20
  local cropDetectParams=30:2

  local -a coord=()
  local line=""
  local x1=99999999999
  local x2=0
  local y1=99999999999
  local y2=0

  while read line; do
    coord=($line)
    [ ${coord[0]} -lt $x1 ] && x1=${coord[0]}
    [ ${coord[1]} -gt $x2 ] && x2=${coord[1]}
    [ ${coord[2]} -lt $y1 ] && y1=${coord[2]}
    [ ${coord[3]} -gt $y2 ] && y2=${coord[3]}
  done < <(
    for i in $(seq $totalLoops); do
      mplayer "$1" -speed 100 -ss "$(( $timeStep * $i ))" -frames $frames -vo null -nosound -nocache -vf cropdetect=$cropDetectParams 2> /dev/null
    done | sed -r -n -e 's/^\[CROP\].+X: ([0-9]+)\.\.([0-9]+).+Y: ([0-9]+)\.\.([0-9]+).*$/\1 \2 \3 \4/p'
  )
  echo $(($x2 - $x1 + 1)):$(($y2 - $y1 + 1)):$x1:$y1
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

# Global series dodona hooks

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

  D_SERIES_PLAYER="mplayer"
  D_SERIES_MV="kde-mv"
  D_SERIES_DO_MV=true
  D_SERIES_PLAYER_ARGS=(-use-filedir-conf)

  # Parse arguments
  local opt
  local OPTIND=1
  local OPTARG

  while getopts rnwf opt "${dodona_ARGS[@]}"; do
    case "$opt" in
      r)  D_SERIES_PLAYER="liveresync"
          D_SERIES_PLAYER_ARGS=(play "${D_SERIES_PLAYER_ARGS[@]}")
          ;;
      n)  D_SERIES_DO_MV=false;;
      w)  D_SERIES_PLAYER_ARGS+=(-aspect 16:9);;
      f)  D_SERIES_PLAYER_ARGS+=(-aspect 4:3);;
    esac
  done
}

# Play the file & move to archive
dodona.user.postFinal() {
  local i
  if [[ -f "${D_SERIES_CHOICE_STACK[0]}" ]]; then
    echo "Playing ${D_SERIES_CHOICE_STACK[0]} (score: ${D_SERIES_SCORE_STACK[0]})" &&
    #"$D_SERIES_PLAYER" -use-filedir-conf -vf-pre crop=$(dodona.user.series.getCropParam "${D_SERIES_CHOICE_STACK[0]}") "${D_SERIES_CHOICE_STACK[0]}" &&
    "$D_SERIES_PLAYER" "${D_SERIES_PLAYER_ARGS[@]}" "${D_SERIES_CHOICE_STACK[0]}" && {
      if "$D_SERIES_DO_MV"; then
        "$D_SERIES_MV" "${D_SERIES_CHOICE_STACK[0]%.*}"* "$D_SERIES_ARCHIVE"
      fi
    } &&
    dodona.user.series.writeStates "${D_SERIES_CHOICE_STACK[0]}"  "$1"
  else
    echo "'${D_SERIES_CHOICE_STACK[0]}' is not a file."
  fi
}
