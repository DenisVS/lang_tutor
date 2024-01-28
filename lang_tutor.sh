#!/bin/sh
### the main program
## version: 2024-01-20-14-10
set -u 
SOURCE_FILE="f:\ob\my_notes\Serbian\phrases.md"
# RESULT_FILE="products_fixed.csv"
#touch "temp_phrases.csv"
#rm "temp_phrases.csv"
#touch "temp_phrases.csv"
SAVEIFS=${IFS} #Устанавливаем разделитель строк
IFS='
'

# Randomize https://stackoverflow.com/questions/2153882/how-can-i-shuffle-the-lines-of-a-text-file-on-the-unix-command-line-or-in-a-shel
INPUT_DATA=$(cat $SOURCE_FILE | shuf)
# for CURRENT_LINE in ${INPUT_DATA}; do
#   #echo $CURRENT_LINE
#   COUNT=$(echo "$CURRENT_LINE" | awk -F \| '{ print $3}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
#   LOSSES=$(echo "$CURRENT_LINE" | awk -F \| '{ print $4  }' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
#   if [ "$LOSSES" = "" ]; then
#     LOSSES=0
#   fi
#   if [ "$COUNT" = "" ]; then
#     COUNT=0
#   fi
#   DIFF=$(expr ${COUNT} - ${LOSSES})
#   CURRENT_SCORED_LINE=$(echo "$CURRENT_LINE" | awk -v DIFF=$DIFF -F \| 'OFS="|"{$5=DIFF ; print ;}')
#   #echo -----
#   SCORED_DATA="$SCORED_DATA
# $CURRENT_SCORED_LINE"
# done

SCORED_DATA=${INPUT_DATA}
# https://unix.stackexchange.com/questions/275794/iterating-over-multiple-CURRENT_LINE-string-stored-in-variable
#echo "$variable" | while IFS= read -r CURRENT_LINE ; do echo $CURRENT_LINE; done
#echo "$SCORED_DATA" | while IFS= read -r CURRENT_LINE; do echo $CURRENT_LINE; done | awk -F\| '{print $0}' | sort -t\| -k5
for CURRENT_LINE in ${SCORED_DATA}; do
  #echo "$CURRENT_LINE"
  QUESTION=$(echo "$CURRENT_LINE" | sed 's/.$//' | awk -F \| '{ print $1}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  # exchanged sed 's/.$//' for sed -e 's/'"`printf '\015'`"'$//' . If necessary, do it in the whole document //todo
  #PROPER_ANSWER=$(echo "$CURRENT_LINE" | sed 's/.$//' | awk -F \| '{ print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -r 's/\ +/\ /g')
  PROPER_ANSWER=$(echo "$CURRENT_LINE" | sed -e 's/'"`printf '\015'`"'$//' | awk -F \| '{ print $2}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -r 's/\ +/\ /g')
  NORMALIZED_PROPER_ANSWER=$(echo "$PROPER_ANSWER" | sed -e 's/\(.*\)/\L\1/' | tr -d '[:punct:]')
  COUNT=$(echo "$CURRENT_LINE" | sed 's/.$//' | awk -F \| '{ print $3}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  LOSSES=$(echo "$CURRENT_LINE" | sed 's/.$//' | awk -F \| '{ print $4}' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
  if [ "$LOSSES" = "" ]; then
    LOSSES=0
  fi
  if [ "$COUNT" = "" ]; then
    COUNT=0
  fi
  COUNT=$(expr ${COUNT} + 1)
  WRONG_ANSWER="1"
  while [ "${WRONG_ANSWER}" = "1" ]; do
    clear
    echo QUESTION: $QUESTION
    read -u 2 -p "Your answer: " USER_ANSWER # Take user input from stderr instead https://unix.stackexchange.com/questions/460266/use-read-as-a-prompt-inside-a-while-loop-driven-by-read
    USER_ANSWER=$(echo $USER_ANSWER | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' | sed -r 's/\ +/\ /g')
    NORMALIZED_USER_ANSWER=$(echo $USER_ANSWER | sed -e 's/\(.*\)/\L\1/' | tr -d '[:punct:]')
    clear
    if [ "$NORMALIZED_USER_ANSWER" = "$NORMALIZED_PROPER_ANSWER" ]; then
      echo Q: $QUESTION
      echo A: $PROPER_ANSWER
    echo _______________________________________________________________________________
      echo Correct!
      WRONG_ANSWER=0
      #echo $QUESTION"|"$PROPER_ANSWER"|"$COUNT"|"$LOSSES >>temp_phrases.csv
    else
      echo PROPER ANSWER: $PROPER_ANSWER
      echo " YOUR ANSWER :" $USER_ANSWER
    echo _______________________________________________________________________________
      echo " Please pay attention to the spelling of the following words:"
      #comm -23 <(echo $NORMALIZED_PROPER_ANSWER | tr ' ' '\n' | sort) <(echo $NORMALIZED_USER_ANSWER | tr ' ' '\n' | sort)
      DIFF_TEXT=`comm -23 <(echo $NORMALIZED_PROPER_ANSWER | tr ' ' '\n' | sort) <(echo $NORMALIZED_USER_ANSWER | tr ' ' '\n' | sort)`
      if [ -n "$DIFF_TEXT" ]    # $string1 не была объявлена или инициализирована.
      then
        for WRONG_WORD in ${DIFF_TEXT}; do
          echo "* $WRONG_WORD"
        done
      else
        echo "*  Incorrect word order in a sentence"
      fi
      LOSSES=$(expr ${LOSSES} + 1)
      #echo $QUESTION"|"$PROPER_ANSWER"|"$COUNT"|"$LOSSES >>temp_phrases.csv

    fi
    #read -u2 -rsn1 -p "Press any key to continue . . ."
    echo _______________________________________________________________________________
    read -u2 -n1 -s -r -p $'Press any key to continue or ESC to exit...\n' key
    #echo $key
    if [ "$key" = $'\e' ]; then
      echo Good by!
      exit
    fi
  done
done
IFS=${SAVEIFS} #возвращаем разделитель строк
#DATE=$(date "+%Y%m%d_%H%M")
#mv $SOURCE_FILE $DATE.csv
#mv temp_phrases.csv $SOURCE_FILE
