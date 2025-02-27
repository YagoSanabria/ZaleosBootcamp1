#!/bin/bash


while [ 1 ] 
do
QUERY=$(nc -u -l 8080 | head -n 1)
	if [ $QUERY="/index" ]
	then
		echo -e "contents.html" | nc -w 0 -u localhost 8080 
	else
		exit 1
	fi
done
