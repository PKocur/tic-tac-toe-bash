#!/bin/bash

BOARD=("-" "-" "-" "-" "-" "-" "-" "-" "-")
DELIMITER_NUMBER=3
TURN=0
GAME_OPTION=0 # 0 - player, 1 - computer

function start() {
  echo
  echo "==========================================="
  echo "Welcome in simple Tic Tac Toe console game!"
  echo "==========================================="
  echo
  choose_game_option
}

function choose_game_option() {
  echo "Press 'p' for playing with another player or 'c' for computer."
  read -r option
  if [ "${#option}" = 1 ] && [[ "${option:0:1}" =~ [pc] ]]; then
    if [[ "${option:0:1}" == "p" ]]; then
      GAME_OPTION=0
      play_with_player 0
    fi
    if [[ "${option:0:1}" == "c" ]]; then
      GAME_OPTION=1
      play_with_computer 0
    fi
  else
    echo "Wrong option. Please try again."
    choose_game_option
  fi
}

function play_with_player() {
  TURN=$1
  while :; do
    show_board
    check_win
    if [[ $((TURN % 2)) == 0 ]]; then
      choose_player_option "X"
    else
      choose_player_option "O"
    fi
    TURN=$((TURN + 1))
  done
}

function play_with_computer() {
  TURN=$1
  while :; do
    show_board
    check_win
    if [[ $((TURN % 2)) == 0 ]]; then
      choose_player_option "X"
    else
      choose_random_place "O"
    fi
    TURN=$((TURN + 1))
  done
}

function choose_random_place() {
  RANDOM_PLACE=$(shuf -i 0-8 -n 1)
  while [ "${BOARD[$RANDOM_PLACE]}" != "-" ]; do
    RANDOM_PLACE=$(shuf -i 0-8 -n 1)
  done
  BOARD[$RANDOM_PLACE]="O"
}

function choose_player_option() {
  echo "Choose place for $1 (numbers 1-9, left to right). Optional save or load game state (s - save, l - load):"
  read -r place
  if [ "${#place}" = 1 ] && [[ "${place:0:1}" =~ [1-9sl] ]]; then
    if [[ "${place:0:1}" == "s" ]]; then
      save
      echo "Saved!"
      choose_player_option "$1"
    elif [[ "${place:0:1}" == "l" ]]; then
      load
      get_turn
      if [ $GAME_OPTION = 0 ]; then
        play_with_player $?
      elif [ $GAME_OPTION = 1 ]; then
        play_with_computer $?
      fi
    elif [ "${BOARD[${place:0:1} - 1]}" == "-" ]; then
      BOARD["${place:0:1}" - 1]="$1"
    else
      echo "Place has been already taken. Please choose another."
      choose_player_option "$1"
    fi
  else
    echo "Wrong place. Please try again."
    choose_player_option "$1"
  fi
}

function show_board() {
  clear
  echo
  for i in "${!BOARD[@]}"; do
    if [ "$i" -ne 0 ] && [ $(("$i" % "$DELIMITER_NUMBER")) = "0" ]; then
      echo
      echo
    fi
    echo -n "${BOARD[$i]}    "
  done
  echo
  echo
}

function win_matches() {
  if [[ ${BOARD[$1]} != "-" ]] && [[ ${BOARD[$1]} == "${BOARD[$2]}" ]] && [[ ${BOARD[$2]} == "${BOARD[$3]}" ]]; then
    echo "Player with ${BOARD[$1]} won! Congratulations!"
    read -r
    exit 1
  fi
}

function check_win() {
  win_matches 0 1 2
  win_matches 3 4 5
  win_matches 6 7 8
  win_matches 0 3 6
  win_matches 1 4 7
  win_matches 2 5 8
  win_matches 0 4 8
  win_matches 2 4 6
  if [ $TURN = 9 ]; then
    echo "Draw."
    read -r
    exit 1
  fi
}

function get_turn() {
  X_COUNT=0
  O_COUNT=0
  for i in "${!BOARD[@]}"; do
    if [ "${BOARD[$i]}" = "O" ]; then
      O_COUNT=$((O_COUNT + 1))
    elif [ "${BOARD[$i]}" = "X" ]; then
      X_COUNT=$((X_COUNT + 1))
    fi
  done
  return $((X_COUNT + O_COUNT))
}

function save() {
  printf "%s\n" "${BOARD[*]}" >tictactoe_save
}

function load() {
  read -r -a BOARD <tictactoe_save
}

start
