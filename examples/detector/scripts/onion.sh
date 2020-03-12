#!/bin/sh
<<<<<<< HEAD

output="onion.tg"
if [ $# -eq 2 ]; then output=$1; fi

cat << EOC > $output
:volu world BOX 100*cm 100*cm 100*cm G4_Galactic
:vis world OFF

:rotm r000 180 0 0

EOC

id=0
while [ $id -le 30 ]; do
  x=$((id*10+10))
  y=$((id*10))
 

  echo ":volu sphere$id SPHERE $y $x 0 360 0 90 G4_Galactic" >>$output 
  echo ":place sphere$id 1 world r000 0 0 0" >> $output
  if (($id%2))
  then
    echo ":color sphere$id 0.0 0.0 1.0" >> $output
  else
    echo ":color sphere$id 1.0 0.0 0.0" >> $output
  fi
  id=$((id+1))
done
=======
output="onion.tg"
echo -n "Creating $output... "

cat << END > $output
// default unit for length is mm
:volu skin50 ORB 50 G4_AIR
:color skin50 0.5 0 0.5

:rotm r000 0 0 0

END

r=45
while [ $r -ge 5 ]; do
  echo ":volu skin$r ORB $r G4_AIR" >> $output
  echo ":place skin$r 1 skin$((r+5)) r000 0 0 0" >> $output
  echo ":color skin$r 0.3 0 0.$r" >> $output
  r=$((r-5))
done
echo Done.
>>>>>>> upstream/master
