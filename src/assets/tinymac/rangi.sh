#!/bin/bash

IFS=$(echo -en "\n\b")
sleep 5
cd /home/pi/Rangi
#gpicview --slideshow rangi.gif & 
sxiv -bfa rangi.gif &
for i in $(ls *.mp3); do 
	omxplayer "$i" --adev local
done;

