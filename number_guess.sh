#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

SECRET_NUMBER=$(( $RANDOM % 1000 + 1 ))

echo "Enter your username:"
read USERNAME

RETURNIG_USER=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
if [[ -z $RETURNIG_USER ]]
then
  INSERTED_USER=$($PSQL "INSERT INTO users (username) values ('$USERNAME')")
  echo "Welcome, $USERNAME! It looks like this is your first time here."
else
  GAMES_PLAYED=$($PSQL "SELECT count(*) FROM games WHERE user_id = $RETURNIG_USER")
  BEST_GAME=$($PSQL "SELECT MIN(guesses) FROM games WHERE user_id = $RETURNIG_USER")
  echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."
fi

echo "Guess the secret number between 1 and 1000:"
read GUESS
TRIES=1

while [[ ! $GUESS =~ ^[0-9]+$ ]]
do
  echo "That is not an integer, guess again:"
  read GUESS
done

while [ ! $GUESS -eq $SECRET_NUMBER ]
do
  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -gt $SECRET_NUMBER ]]
    then
      echo "It's higher than that, guess again:"
      read GUESS
    elif [[ $GUESS -lt $SECRET_NUMBER ]]
    then
      echo "It's lower than that, guess again:"
      read GUESS
    fi
  fi
  
  TRIES=$(expr $TRIES + 1)
done

USER_ID=$($PSQL "SELECT user_id FROM users WHERE username = '$USERNAME'")
INSERTED_GAME=$($PSQL "INSERT INTO games (user_id, guesses) values ($USER_ID, $TRIES)")

echo "You guessed it in $TRIES tries. The secret number was $SECRET_NUMBER. Nice job!"
