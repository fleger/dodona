#! /bin/bash

# Node Type: Show
dodona.user.preChildren() {
  D_SERIES_SHOW="$1"
  cd "$1"
  if [[ -f "$D_SERIES_PERSIST" ]]; then
    D_SERIES_CURRENT_SEASON="""$(cat "$D_SERIES_PERSIST")"""
    D_SERIES_CURRENT_SEASON_SET=false
  else
    D_SERIES_NO_CURRENT_SEASON_SET=true
  fi
  D_SERIES_IS_NEXT_SEASON=false
  D_SERIES_BEST_SEASON_CHOICE=""
  D_SERIES_BEST_SEASON_SCORE=0
}

dodona.user.postChildren() {
  local lastIndex=$(( ${#D_SERIES_SCORE_STACK[@]} - 1))
  D_SERIES_SCORE_STACK[$lastIndex]=$(( ${D_SERIES_SCORE_STACK[$lastIndex]} * $D_SERIES_BEST_SEASON_SCORE ))
  D_SERIES_CHOICE_STACK[$(( ${#D_SERIES_CHOICE_STACK[@]} - 1))]="$D_SERIES_BEST_SEASON_CHOICE"
  echo ${D_SERIES_CHOICE_STACK[$(( ${#D_SERIES_CHOICE_STACK[@]} - 1))]}
}


dodona.user.preChild() {
  echo "prechild"
  D_SERIES_SEASON=""
  D_SERIES_CHOICE_STACK+=("")
  D_SERIES_SCORE_STACK+=(1)
}

dodona.user.postChild() {
  echo "postchild $D_SERIES_SEASON"
  # We begin a new series
  $D_SERIES_NO_CURRENT_SEASON &&
  D_SERIES_CURRENT_SEASON="$D_SERIES_SEASON" &&
  D_SERIES_NO_CURRENT_SEASON=false

  # Retreive season best score & episode name
  local lastIndex
  lastIndex=$(( ${#D_SERIES_SCORE_STACK[@]} - 1))
  local seasonScore=${D_SERIES_SCORE_STACK[$lastIndex]}
  unset D_SERIES_SCORE_STACK[$lastIndex]
  lastIndex=$(( ${#D_SERIES_CHOICE_STACK[@]} - 1))
  local episodeName=${D_SERIES_CHOICE_STACK[$lastIndex]}
  unset D_SERIES_CHOICE_STACK[$lastIndex]
  
  # Apply modifiers to score
  # Next season
  $D_SERIES_IS_NEXT_SEASON &&
  score=$(( score * $D_SERIES_SCORE_NEXT_SEASON )) &&
  D_SERIES_IS_NEXT_SEASON=false
  # Current season
  [ "$D_SERIES_SEASON" = "$D_SERIES_CURRENT_SEASON" ] &&
  score=$(( score * $D_SERIES_SCORE_CURRENT_SEASON )) &&
  D_SERIES_IS_NEXT_SEASON=true
  echo "$episodeName: $score"
  # Update best score
  (( $score > $D_SERIES_BEST_SEASON_SCORE )) &&
  D_SERIES_BEST_SEASON_SCORE=$score &&
  D_SERIES_BEST_SEASON_CHOICE=$episodeName
}
 


