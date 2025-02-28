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

#SERVER->CLIENTE: 1 LINEAS: CONTENTS+CKSUM
send(){	#$1 sendInfo
	RESPONSE=$1
	FINALRESPONSE=$(echo "$RESPONSE $(echo $RESPONSE | cksum)")
	echo "$FINALRESPONSE" |nc -w 0 -u localhost 8080
	echo "Sending: $FINALRESPONSE"

}

#CLIENTE->SERVER: 1 LINEAS: CONTENTS+CKSUM separados por columnas
QUERY=""
recv(){
	QUERY=""
	QUERY=$(nc -u -l 8080 | head -n 1)
	URI=$(echo $QUERY | awk '{print $1}')
	CKSUM=$(echo $QUERY | awk '{print $2}')
	ACTUALCKSUM=$(echo $URI | cksum | awk '{print $1}')

	echo "Parameters: QUERY: $QUERY,URI: $URI,CKSUM: $CKSUM,ACTUALCKSUM:$ACTUALCKSUM"

	if [ $CKSUM = $ACTUALCKSUM ]
	then
		echo "GET REQUEST ACCEPTED TO $URI"
		QUERY=$URI
	fi
}

while [ 1 ] 
do
recv
echo "GET request for $QUERY"

	if [ "$QUERY" = "/index" ]
	then
		RESPONSE=$(cat web/index.html | tr -d '\n')
		send "$RESPONSE"
	elif [ "$QUERY" = "/quijote" ]
	then
	RESPONSE=$(cat web/quijote.txt | tr '\n' ' ')
		send "$RESPONSE"
	elif [ "$QUERY" = "/quijote/grep" ]
	then
		RESPONSE=$(cat web/quijote.txt | grep -o "pr[a-z]*\ " | tr '\n' ' ') #Todo lo que empiece por pr: "pr[a-z]*\ " 
		cat "$RESPONSE"
		send "$RESPONSE"
	else
		RESPONSE=$(cat web/errpage.html | tr -d '\n')
		send "$RESPONSE"
	fi
	echo "QUERY RESPONDED"
done



exit 0