#! /bin/bash

# Node Type: Show
# Does not work yet?

# So the scores should be:
# - D_SERIES_SCORE_EXHAUSTED for all watched seasons,
# - D_SERIES_SCORE_NEXTFILE for all unwatched seasons except the current one and the next one,
# - D_SERIES_SCORE_NEXTFILE * D_SERIES_SCORE_CURRENT_SEASON for current season,
# - D_SERIES_SCORE_EXHAUSTED * D_SERIES_SCORE_CURRENT_SEASON if the current season is finished,
# - D_SERIES_SCORE_NEXTFILE * D_SERIES_SCORE_NEXT_SEASON for the next season,
# - D_SERIES_SCORE_EXHAUSTED * D_SERIES_SCORE_NEXT_SEASON if the next season is empty or completely
#   watched, which can not happen.

dodona.user.preChildren() {
  D_SERIES_SHOW="$1"
  cd "$1"
  # Try to load the show state file
  # Put the current season in D_SERIES_CURRENT_SEASON
  if [[ -f "$D_SERIES_PERSIST" ]]; then
    D_SERIES_CURRENT_SEASON="$(cat $D_SERIES_PERSIST)"
  else
    D_SERIES_CURRENT_SEASON=""
  fi
  # Flag indicating that the child that has been treated is the next season
  D_SERIES_IS_NEXT_SEASON=false
  D_SERIES_BEST_SEASON_CHOICE=""
  D_SERIES_BEST_SEASON_SCORE=0
}

dodona.user.postChildren() {
  D_SERIES_SCORE_STACK[0]=$(( ${D_SERIES_SCORE_STACK[0]} * $D_SERIES_BEST_SEASON_SCORE ))
  D_SERIES_CHOICE_STACK[0]="$D_SERIES_BEST_SEASON_CHOICE"
}


dodona.user.preChild() {
  # Reset variables before entering a new season
  D_SERIES_SEASON=""
  D_SERIES_CHOICE_STACK=("" "${D_SERIES_CHOICE_STACK[@]}")
  D_SERIES_SCORE_STACK=(1 "${D_SERIES_SCORE_STACK[@]}")
}

dodona.user.postChild() {
  # Case: start a new series. Pick up the first season as the current season.
  [ "x$D_SERIES_CURRENT_SEASON" = "x" ] &&
  D_SERIES_CURRENT_SEASON="$D_SERIES_SEASON"

  # Retreive season best score & episode name
  local score=${D_SERIES_SCORE_STACK[0]}
  D_SERIES_SCORE_STACK=("${D_SERIES_SCORE_STACK[@]:1}")
  local episodeName=${D_SERIES_CHOICE_STACK[0]}
  D_SERIES_CHOICE_STACK=("${D_SERIES_CHOICE_STACK[@]:1}")

  # Apply modifiers to score
  # Case: weigh the season immediately following the current registered one
  $D_SERIES_IS_NEXT_SEASON &&
  score=$(( score * $D_SERIES_SCORE_NEXT_SEASON )) &&
  D_SERIES_IS_NEXT_SEASON=false

  # Case: weigh the current registered season
  # If we have ran out of episodes, score should be D_SERIES_SCORE_EXHAUSTED (0)
  [ "x$D_SERIES_SEASON" = "x$D_SERIES_CURRENT_SEASON" ] &&
  score=$(( score * $D_SERIES_SCORE_CURRENT_SEASON )) &&
  D_SERIES_IS_NEXT_SEASON=true

  # Update best score
  (( $score > $D_SERIES_BEST_SEASON_SCORE )) &&
  D_SERIES_BEST_SEASON_SCORE=$score &&
  D_SERIES_BEST_SEASON_CHOICE=$episodeName
}



