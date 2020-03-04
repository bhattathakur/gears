#!/bin/sh

output="onion.tg"
if [ $# -eq 2 ]; then output=$1; fi

cat << EOC > $output
:volu world BOX 100*cm 100*cm 100*cm G4_Galactic
:vis world OFF

:rotm r000 180 0 0

EOC

id=0
while [ $id -le 10 ]; do
  x=$((id*10+10))
  y=$((id*10))
 
  echo ":volu sphere$id SPHERE $y $x 0 360 0 90 G4_Galactic" >>$output 
  echo ":place sphere$id 1 world r000 0 0 0" >> $output
  echo ":color sphere$id 0.75 0.3 0.3" >> $output
  id=$((id+1))
done
