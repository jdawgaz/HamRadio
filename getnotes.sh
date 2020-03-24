#!/usr/bin/env bash

# Author: Jerry Davis, K7AZJ
#
# this script downloads all the requested amateurlogic.tv episode notes
# and converts them to text using a html to text converter
#
# usage: getnotes.sh start [end]
#  examples: getnotes.sh 95 : denotes 95 to last episode"
#            getnotes.sh 95 95 : denotes only episode 95"
#            getnotes.sh 95 105 : denotes only episodes 95-105"
#
# be sure to do a chmod u+x on this file, to make it executable
#
# you can use curl instead of wget, if you want. just change the wget line to
# whatever you want.
#
# substitute your own html to text converter, for the last line
# I have heard good things about the python htmltotext converter
#
# Once you have downloaded all the episodes, and keep doing that,
# you can go to the directory, and do a grep of all the files, and
# search for what you want.

#template: http://amateurlogic.tv/wiki/doku.php?id=amateurlogic_episode_1

mkdir -p $HOME/Documents/amateurLogic
cd $HOME/Documents/amateurLogic

wget -q https://amateurlogic.tv/wiki/doku.php?id=amateurlogic_episode_monthly -O episodes.html
html2text episodes.html > episodes.txt
cnt=$(grep 'AmateurLogic_Episode_' episodes.txt | head -1 | sed 's/* AmateurLogic_Episode_//' | cut -d: -f1 | tr -d ' ')

if [ -z "$1" ]; then
  echo -e "usage: getnotes.sh start [end]"
  echo -e "   examples: getnotes.sh 95 : denotes 95 to last episode"
  echo -e "             getnotes.sh 95 95 : denotes only episode 95"
  echo -e "             getnotes.sh 95 105 : denotes only episodes 95-105"

  echo "   there appears to be $cnt episodes"
  
  exit 1
fi

lv=$1

if [ -z "$2" ]; then
  lv="$lv $cnt"
else
  lv="$lv $2"
fi

for i in `seq $lv`
do
  echo getting episode "$i"
  wget -q http://amateurlogic.tv/wiki/doku.php?id=amateurlogic_episode_$i -O episode_$i.html
done

for f in *.html; do
  nf=${f%.html}
  html2text "$f" > "${nf}.txt"
  rm "$f"
done
