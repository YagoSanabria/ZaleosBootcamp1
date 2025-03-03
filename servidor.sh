#!/bin/bash
PORT=8080

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

#SERVER->CLIENTE: 1 LINEAS: CONTENTS+CKSUM
send(){	#$1 sendInfo
	RESPONSE=$1
	FINALRESPONSE=$(echo "$RESPONSE $(echo $RESPONSE | cksum)")
	echo "$FINALRESPONSE" |nc -w 0 -u localhost $PORT
	#echo "Sending: $FINALRESPONSE"

}

#CLIENTE->SERVER: 1 LINEAS: CONTENTS+CKSUM separados por columnas
QUERY=""
recv(){
	QUERY=""
	QUERY=$(nc -u -l $PORT | head -n 1)
	URI=$(echo $QUERY | awk '{print $1}')
	CKSUM=$(echo $QUERY | awk '{print $2}')
	ACTUALCKSUM=$(echo $URI | cksum | awk '{print $1}')

	echo "Parameters: QUERY: $QUERY,URI: $URI,CKSUM: $CKSUM,ACTUALCKSUM:$ACTUALCKSUM"

	if [ $CKSUM = $ACTUALCKSUM ]
	then
		echo "REQUEST ACCEPTED TO $URI"
		QUERY=$URI
	fi
}

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
	cumpleRegex "$URI" "^/index" 
	if [ $CUMPLEREGEX -eq 1 ]
	then
		RESPONSE=$(cat web/index.html | tr -d '\n')
		send "$RESPONSE"
		continue
	fi

	#GET /quijote
	cumpleRegex "$URI" "^/quijote$" 
	if [ $CUMPLEREGEX -eq 1 ]
	then
		RESPONSE=$(cat web/quijote.txt | tr '\n' ' ')
		send "$RESPONSE"
		continue
	fi

	#GET /quijote/grep?regex=...
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
				echo "$ARGVALUE"
			fi
		done

		RESPONSE=$(cat "web/quijote.txt" | grep -oE "$REGEXVALUE" | tr '\n' ' ')
		NULLRESPONSE=$(echo $RESPONSE | wc -m)
		
		if [ $NULLRESPONSE -eq 1 ]
		then
			RESPONSE="No match was found to regex: $ARGVALUE"
		fi
		echo "LA RESPUESTA ES $RESPONSE"
		send "$RESPONSE"
		continue
	fi

	RESPONSE=$(cat web/errpage.html | tr -d '\n')
	send "$RESPONSE"
done
exit 0