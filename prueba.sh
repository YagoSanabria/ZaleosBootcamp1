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
echo "GET request for $QUERY"

read -p "Enter a QUERY [with/not a regex after '&']: " QUERY



	ARGS=$(echo -e "$QUERY" | grep -o "[?&][a-zA-Z0-9=]*" | sed "1s/\?/\&/")

	URI=$(echo -e  "$QUERY" | grep -oE "/[a-z0-9]+\?" | tr -d "?")

	if [ "$URI" = "" ]
	then 
		echo "Wrong use: please provide valir URL </example?example>"
		continue
	fi
	
	echo "we are in: $URI"
	#pr[a-z]\*

	for INFO in $ARGS
	do
		echo "$INFO" | tr -d "&"

		cat "web/quijote.txt" | grep -oE "$INFO" | tr '\n' ' '

	done








	
	#else
		#RESPONSE=$(cat web/errpage.html | tr -d '\n')
		#echo -e "$RESPONSE"
	#fi
	echo "QUERY RESPONDED"
done



exit 0