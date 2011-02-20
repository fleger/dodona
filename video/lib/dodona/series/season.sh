#! /bin/bash

# Node Type: Season
dodona.user.postChildren() {
  echo "In season $1"
  cd "$1"
  local score=$D_SERIES_SCORE_EXHAUSTED
  local flag
  local lastItem
  local newItem
  if [ -f "$1/$D_SERIES_PERSIST" ]; then
    lastItem="""$(cat "$1/$D_SERIES_PERSIST")"""
    flag=false
    for f in $(ls *.@(avi|mkv|mp4|flv|wmv|mpg|mpeg|ogm)); do
      $flag && newItem="$f" && score=$D_SERIES_SCORE_NEXTFILE && break
      [[ "$f" = "$lastItem" ]] && flag=true
    done
  else
    for f in $(ls *.@(avi|mkv|mp4|flv|wmv|mpg|mpeg|ogm)); do
      newItem="$f" && score=$D_SERIES_SCORE_NEXTFILE && break
    done
  fi
  local lastIndex=$(( ${#D_SERIES_SCORE_STACK[@]} - 1))
  D_SERIES_SCORE_STACK[$lastIndex]=$(( ${D_SERIES_SCORE_STACK[$lastIndex]} * $score ))
  D_SERIES_CHOICE_STACK[$(( ${#D_SERIES_CHOICE_STACK[@]} - 1))]="$1/$newItem"
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

