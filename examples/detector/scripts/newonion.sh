#!/bin/sh

output="newonion.tg"
if [ $# -eq 2 ]; then output=$1; fi

cat << EOC > $output
:volu world BOX 100*cm 100*cm 100*cm G4_Galactic
:vis world OFF

:rotm r000 0 0 0

EOC

id=20
num=20
while [ $id -ge 1 ]; do
  #x=$((id*10+10))
  x=$((id*10))
 
  echo ":volu sphere$id SPHERE 0 $x 0 360 0 90 G4_Galactic" >>$output 
  if [ $id == "20" ];then
    echo ":place sphere$id 1 world r000 0 0 0" >> $output
  else
    echo ":place sphere$id 1 sphere$(( $id+1 )) r000 0 0 0" >> $output
  fi
  if (($id%2))
  then
    echo ":color sphere$id 0.0 0.0 1.0" >> $output
  else
    echo ":color sphere$id 1.0 0.0 0.0" >> $output
  fi
  id=$((id-1))
done
