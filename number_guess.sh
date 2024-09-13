#!/bin/bash

PSQL="psql -U freecodecamp -d number_guess -t --no-align -c"

MAIN() {
  echo "Enter your username:"
  read USERNAME

  GET_USER $USERNAME

  if [[ -z $USER ]]
  then
    ADD_NEW_USER $USERNAME
  else
    SHOW_USER_STATS $USER "$USERNAME"
  fi

  GUESS_NUMBER
  UPDATE_USER_DATA $USER $USERNAME  

  echo "You guessed it in $CURRENT_SCORE tries. The secret number was $NUMBER. Nice job!"

}

GUESS_NUMBER() {
  NUMBER=$((1 + $RANDOM % 1000))
  echo $NUMBER
  CURRENT_SCORE=0

  echo -e "Guess the secret number between 1 and 1000:"
  read USER_NUMBER
  while [[ $USER_NUMBER -ne $NUMBER ]]
  do
    if ! [[ $USER_NUMBER =~ ^[0-9]+$ ]]
    then
      echo -e "\nThat is not an integer, guess again:"
      read USER_NUMBER
    else
      if (( $USER_NUMBER < $NUMBER ))
      then
        CURRENT_SCORE=$(($CURRENT_SCORE + 1))
        echo -e "\nIt's lower than that, guess again:"
        read USER_NUMBER
      else
        CURRENT_SCORE=$(($CURRENT_SCORE + 1))
        echo -e "\nIt's higher than that, guess again:"
        read USER_NUMBER
      fi
    fi
  done

  CURRENT_SCORE=$(($CURRENT_SCORE + 1))

}

GET_USER() {
  USER=$($PSQL "SELECT games_total, best_game_score FROM users WHERE username ILIKE '$1';")
}

ADD_NEW_USER() {
  echo "Welcome, $1! It looks like this is your first time here."
  INSERTED=$($PSQL "INSERT INTO users (username) VALUES('$1');")
  USER=$($PSQL "SELECT games_total, best_game_score FROM users WHERE username ILIKE '$1';")
}

SHOW_USER_STATS() {
  echo $1 | while IFS="|" read TOTAL_GAMES BEST_SCORE
  do
    echo -e "Welcome back, $2! You have played $TOTAL_GAMES games, and your best game took $BEST_SCORE guesses.\n"
  done
}

UPDATE_USER_DATA() {
  echo "$1" | while IFS="|" read TOTAL_GAMES BEST_SCORE
  do
    TOTAL_GAMES=$(($TOTAL_GAMES + 1))
    if (( $BEST_SCORE == 0)) || (( $CURRENT_SCORE < $BEST_SCORE ))
    then
      BEST_SCORE=$CURRENT_SCORE
    fi
    UPDATE=$($PSQL "UPDATE users SET games_total = $TOTAL_GAMES, best_game_score = $BEST_SCORE WHERE username ILIKE '$2';")
  done 
}

MAIN