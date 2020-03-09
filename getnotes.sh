#!/usr/bin/env bash

# Author: Jerry Davis, K7AZJ
#
# this script downloads all the requested amateurlogic.tv episode notes
# and converts them to text using a html to text converter
#
# usage: getnotes.sh 'range'
#  where range is in quotes, and can be any range that you need:
#        '1 95' for the first through the 95th episode
#        '96 96' for only the 96th episode, for instance
#
# be sure to do a chmod u+x on this file, to make it executable
#
# you can use wget instead of curl, if you want. just change the curl line to
# whatever you want.
#
# substitute your own html to text converter, for the last line
# I have heard good things about the python htmltotext converter


#template: http://amateurlogic.tv/wiki/doku.php?id=amateurlogic_episode_1

mkdir -p $HOME/Documents/amateurLogic
cd $HOME/Documents/amateurLogic

if [ -z "$1" ]; then
  echo -e "usage: getnotes.sh 'range'\n   where range is '95 95' for episode 95,\n   or '1 95' for all episodes"

  wget -q https://amateurlogic.tv/wiki/doku.php?id=amateurlogic_episode_monthly -O episodes.html
  html2text episodes.html > episodes.txt
  cnt=$(grep 'AmateurLogic_Episode_' episodes.txt | head -1 | sed 's/* AmateurLogic_Episode_//' | cut -d: -f1 | tr -d ' ')
  echo "   there appears to be $cnt episodes"
  
  exit 1
fi

lv=$1

for i in `seq $lv`
do
  wget -q http://amateurlogic.tv/wiki/doku.php?id=amateurlogic_episode_$i -O episode_$i.html
done

for f in *.html; do
  nf=${f%.html}
  html2text "$f" > "${nf}.txt"
  rm "$f"
done

