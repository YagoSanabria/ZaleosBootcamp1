#!/bin/bash

CUMPLEREGEX=0
function cumpleRegex(){
	STRING="$1"
	REGEX="$2"
	if [[ $STRING =~ $REGEX ]]
	then
		echo "CUMPLE"
	fi
}

while [ 1 ] 
do
QUERY=$(nc -u -l 8080 | head -n 1)
echo "GET request for $QUERY"

	if [ $QUERY = "/index" ]
	then
		RESPONSE=$(cat web/index.html | tr -d '\n')
		echo $RESPONSE | nc -w 0 -u localhost 8080 
	elif [[ $QUERY =~ ^/regex/.*/.*$ ]]
	then
		PALABRA=echo $QUERY | #echo $IN | tr ";" "\n" 

		REGEX=
		cumpleRegex()
	else
		RESPONSE=$(cat web/errpage.html | tr -d '\n')
		echo $RESPONSE | nc -w 0 -u localhost 8080 
	fi


done



exit 0