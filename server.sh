#!/bin/bash

#Version of netcat needed: OpenBSD metcat (Debian patchlevel 1.226-1ubuntu2)
#If not, wrong behaviour of netcat can occur

PORT=8080

ISREGEX=0
function isRegex(){
	ISREGEX=0
	STRING="$1"
	REGEX="$2"
	if [[ $STRING =~ $REGEX ]]
	then
		ISREGEX=1
	fi
}

ARGNAME=0
ARGVALUE=0
function translateArgument(){
	ARGNAME=$(echo $1 |  grep -oE '^[^=]+')
	ARGVALUE=$(echo $1 | grep -oE '=[^=]*' | sed "1s/\=//")
}

#SERVER->CLIENT: 1 LINE: CONTENTS+CKSUM
send(){	#$1 arg = sendInfo
	RESPONSE=$1
	FINALRESPONSE=$(echo "$RESPONSE $(echo $RESPONSE | cksum)")
	echo "$FINALRESPONSE" |nc -w 0 -u localhost $PORT
}

#CLIENT->SERVER: 1 LINE: CONTENTS+CKSUM divided by columns
QUERY=""
recv(){
	QUERY=""
	QUERY=$(nc -u -l $PORT | head -n 1)
	URI=$(echo $QUERY | awk '{print $1}')
	CKSUM=$(echo $QUERY | awk '{print $2}')
	ACTUALCKSUM=$(echo $URI | cksum | awk '{print $1}')

	if [ $CKSUM = $ACTUALCKSUM ]
	then
		echo "REQUEST ACCEPTED TO $URI"
		QUERY=$URI
	fi
}

#server loop
while [ 1 ] 
do
	recv
	echo "GET request for $QUERY"

	URI=$(echo -e  "$QUERY" | grep -oE "/[a-z0-9/]+(\?|$)" | tr -d "?")
	ARGS=$(echo -e "$QUERY" | grep -oP "[?&][.,\")(a-zA-Z0-9=\*\]\[\-]*" | sed "1s/\?/\&/")
	echo "$URI $ARGS"

	#Error prevention
	if [ "$URI" = "" ]
	then 
		echo "Wrong use: please provide valir URL </example?example>"
		continue
	fi

	#GET /index
	isRegex "$URI" "^/index" 
	if [ $ISREGEX -eq 1 ]
	then
		RESPONSE=$(cat web/index.html | tr -d '\n')
		send "$RESPONSE"
		continue
	fi

	#GET /quijote
	isRegex "$URI" "^/quijote$" 
	if [ $ISREGEX -eq 1 ]
	then
		RESPONSE=$(cat web/quijote.txt | tr '\n' ' ')
		send "$RESPONSE"
		continue
	fi

	#GET /quijote/grep?regex=...
	isRegex "$URI" "^/quijote/grep" #ISREGEX
	if [ $ISREGEX -eq 1 ]
	then
		REGEXVALUE=0
		for INFO in $ARGS
		do
			ARG=$(echo "$INFO" | sed 's/^&//')
			translateArgument $ARG
			if [ $ARGNAME = "regex" ]
			then
				REGEXVALUE=$ARGVALUE
				echo "$ARGVALUE"
			fi
		done

		RESPONSE=$(cat "web/quijote.txt" | grep -oE "$REGEXVALUE" | tr '\n' ' ')
		NULLRESPONSE=$(echo $RESPONSE | wc -m)
		
		if [ $NULLRESPONSE -eq 1 ]
		then
			RESPONSE="No match was found for regex: $ARGVALUE"
		fi
		echo "Anser is: $RESPONSE"
		send "$RESPONSE"
		continue
	fi

	RESPONSE=$(cat web/errpage.html | tr -d '\n')
	send "$RESPONSE"
done
#exit
exit 0