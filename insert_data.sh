#! /bin/bash

if [[ $1 == "test" ]]
then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Do not change code above this line. Use the PSQL variable above to query your database.

echo $($PSQL "Truncate games, teams RESTART IDENTITY CASCADE")

cat games.csv | while IFS="," read YEAR ROUND WINNER OPPONENT WINNER_GOALS OPPONENT_GOALS
do
  if [[ $YEAR != "year" ]]
  then
    #GET TEAM 
    TEAM_ID_WINNER=$($PSQL "SELECT team_id from teams where name = '$WINNER'")
    if [[ -z $TEAM_ID_WINNER ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "Insert into teams(name) values('$WINNER')")
      if [[ $INSERT_TEAM_RESULT  == "INSERT 0 1" ]]
      then
        echo "Inserted into games, $WINNER"
      fi
      TEAM_ID_WINNER=$($PSQL "SELECT team_id FROM teams WHERE name='$WINNER'")
    fi

    TEAM_ID_OPPONENT=$($PSQL "SELECT team_id from teams where name = '$OPPONENT'")

    if [[ -z $TEAM_ID_OPPONENT ]]
    then
      INSERT_TEAM_RESULT=$($PSQL "Insert into teams(name) values('$OPPONENT')")
      if [[ $INSERT_TEAM_RESULT  == "INSERT 0 1" ]]
      then
        echo "Inserted into games, $OPPONENT"
      fi
      TEAM_ID_OPPONENT=$($PSQL "SELECT team_id FROM teams WHERE name='$OPPONENT'")
    fi

    # Insertar en la tabla games
    INSERT_GAME_RESULT=$($PSQL "INSERT INTO games(year, round, winner_id, opponent_id, winner_goals, opponent_goals) VALUES($YEAR, '$ROUND', $TEAM_ID_WINNER, $TEAM_ID_OPPONENT, $WINNER_GOALS, $OPPONENT_GOALS)")
    if [[ $INSERT_GAME_RESULT == "INSERT 0 1" ]]
    then
      echo "Inserted into games: $YEAR $ROUND $WINNER vs $OPPONENT"
    fi

  fi

done

#create table games(game_id serial primary key, year int not null, round varchar(50) not null, winner varchar(50) not null, opponent varchar(50) not null, winner_goals int not null, opponent_goals int not null);