#! /bin/bash

# Node Type: Season
dodona.user.postChildren() {
  echo "In season $1"
  cd "$1"
  local score=$D_SERIES_SCORE_EXHAUSTED
  local flag
  local lastItem
  local newItem
  local f
  cd "$1"
  if [ -f "$1/$D_SERIES_PERSIST" ]; then
    lastItem="$(cat $1/$D_SERIES_PERSIST)"
    flag=false
    # FIXME: if lastFile is missing, it wont work
    # Try inserting lastFile at the end of the ls then sort then uniq
    for f in $(dodona.user.series.quicksort "$lastItem" ${D_SERIES_VIDEO_PATTERNS[@]}); do
      $flag && newItem="$f" && score=$D_SERIES_SCORE_NEXTFILE && break
      [[ "$f" = "$lastItem" ]] && flag=true
    done
  else
    for f in $(dodona.user.series.quicksort ${D_SERIES_VIDEO_PATTERNS[@]}); do
      newItem="$f" && score=$D_SERIES_SCORE_NEXTFILE && break
    done
  fi
  # WTF?
  D_SERIES_SCORE_STACK[0]=$(( ${D_SERIES_SCORE_STACK[0]} * $score ))
  D_SERIES_CHOICE_STACK[0]="$1/$newItem"
}

dodona.user.preChild() {
  true
}

dodona.user.postChild() {
  true
}

dodona.user.preChildren() {
  D_SERIES_SEASON="$1"
}

