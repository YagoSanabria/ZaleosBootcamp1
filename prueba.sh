#!/bin/bash

CUMPLEREGEX=0
function cumpleRegex(){
	CUMPLEREGEX=0
	STRING="$1"
	REGEX="$2"
	if [[ $STRING =~ $REGEX ]]
	then
		CUMPLEREGEX=1
	fi
}

ARGNAME=0
ARGVALUE=0
function translateArgument(){
ARGNAME=$(echo $1 |  grep -oE '^[^=]+')
ARGVALUE=$(echo $1 | grep -oE '=[^=]*' | sed "1s/\=//")
}

while [ 1 ] 
do
read -p "Enter a QUERY [with/not a regex after '&']: " QUERY
echo "GET request for $QUERY"

	URI=$(echo -e  "$QUERY" | grep -oE "/[a-z0-9/]+(\?|$)" | tr -d "?")
	ARGS=$(echo -e "$QUERY" | grep -oP "[?&][)(a-zA-Z0-9=\*\]\[\-]*" | sed "1s/\?/\&/")

	if [ "$URI" = "" ]
	then 
		echo "Wrong use: please provide valir URL </example?example>"
		continue
	fi

	#GET /quijote/grep?regex=
	cumpleRegex "$URI" "^/quijote/grep" #CUMPLEREGEX
	if [ $CUMPLEREGEX -eq 1 ]
	then
		REGEXVALUE=0
		for INFO in $ARGS
		do
			ARG=$(echo "$INFO" | sed 's/^&//')
			translateArgument $ARG
			if [ $ARGNAME = "regex" ]
			then
				REGEXVALUE=$ARGVALUE
			fi
		done

		echo "value: $REGEXVALUE"
		cat "web/quijote.txt" | grep -oE "$REGEXVALUE" | tr '\n' ' '

		continue
	fi
	# GET /quijote
	cumpleRegex "$URI" "^/quijote$" 
	if [ $CUMPLEREGEX -eq 1 ]
	then
		RESPONSE=$(cat web/quijote.txt | tr '\n' ' ')
		send "$RESPONSE"
		continue
	fi

	RESPONSE=$(cat web/errpage.html | tr -d '\n')
	echo -e "$RESPONSE"

done



exit 0