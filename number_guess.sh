#!/bin/bash
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"

NUMBER_GUESS() {
#generate random number
NUMBER=$(( RANDOM%1000 + 1 ))
echo $NUMBER
echo Enter your username:
read USERNAME

# if username doesn't exist in the database
USERNAME_CHECK=$($PSQL "select username from user_stats where username = '$USERNAME';")
if [[ -z $USERNAME_CHECK ]]
then
  INSERT_USER=$($PSQL "insert into user_stats(username, games_played, best_game) values('$USERNAME', 0, 0);")
  GAME_STATS=$($PSQL "select username, games_played, best_game from user_stats where username = '$USERNAME';")
  IFS='|' read -r USERNAME GAMES_PLAYED BEST_GAME <<< "$GAME_STATS"
  echo Welcome, $USERNAME! It looks like this is your first time here.
else 
  GAME_STATS=$($PSQL "select games_played, best_game from user_stats where username = '$USERNAME';")
  IFS='|' read -r GAMES_PLAYED BEST_GAME <<< "$GAME_STATS"
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi
echo Guess the secret number between 1 and 1000:
read GUESS
COUNT=1
while ! [[ $GUESS =~ ^[0-9]+$ ]]
do
echo That is not an integer, guess again:
read GUESS
((COUNT++))
done
UPDATE_GAMES_PLAYED=$($PSQL "update user_stats set games_played = $GAMES_PLAYED + 1 where username = '$USERNAME';")
while (( $GUESS != $NUMBER ))
do
if (( $GUESS > $NUMBER ))
then
echo "It's lower than that, guess again:"
read GUESS
((COUNT++))
elif (( $GUESS < $NUMBER ))
then
echo "It's higher than that, guess again:"
read GUESS
((COUNT++))
fi
done
if (( $BEST_GAME == 0 )) || (( $COUNT < $BEST_GAME ))
then 
  UPDATE_BEST_GAME=$($PSQL "update user_stats set best_game = $COUNT where username = '$USERNAME';")
fi
echo You guessed it in $COUNT tries. The secret number was $NUMBER. Nice job!
}

NUMBER_GUESS