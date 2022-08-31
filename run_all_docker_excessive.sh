#!/bin/bash
IFS=$'\n' read -d '' -r -a lines < resources.txt

for i in {1..$1..1} :
do
  for i in "${lines[@]}"
  do
     echo "$i"
     export URL=$i
     docker run --platform linux/amd64 -d  alpine/bombardier -c 300 -d 60000h -l $URL &
  done
done
