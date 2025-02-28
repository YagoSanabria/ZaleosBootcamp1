#!/bin/bash

#CLIENTE->SERVER: 1 LINEA: CONTENTS+CKSUM separado por columnas
function send(){	#$1 sendInfo
	RESPONSE=$1
    CKSUM=$(echo "$RESPONSE" | cksum)

	SENDING="$RESPONSE $CKSUM"
	echo "Sending: $SENDING"
	echo "$SENDING"|nc -w 0 -u localhost 8080
}


#SERVER->CLIENTE: 1 LINEAS CONTENTS+CKSUM
#Escritura al servidor
WEBPATH="/tmp/APIwebpage.html"
recv(){
	RESPONSE=$(nc -u -l 8080 | head -n 1)
	echo "response is $RESPONSE"
	REVCKSUM=$(echo "$RESPONSE" | rev | awk '{print $2}')
	echo "revchecksum $REVCKSUM"

	RESPONSE=$(echo ${RESPONSE} | sed 's/ [0-9]* [0-9]*$//')
	echo "RESPONSE $RESPONSE"  > $WEBPATH
	echo "REV: $REVCKSUM"
}

#check correct usage
if [ $# -eq 0 ]
then

	echo -e "Error: Incorrect usage of client.sh\nUse: $0 <param>"
	exit 1
fi

send $1

recv

echo "Exited successfully"
firefox  $WEBPATH &
exit 0



