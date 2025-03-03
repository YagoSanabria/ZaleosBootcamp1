#!/bin/bash

PORT=8080

#CLIENTE->SERVER: 1 LINEA: CONTENTS+CKSUM separado por columnas
function send(){	#$1 sendInfo
	RESPONSE=$1
    CKSUM=$(echo "$RESPONSE" | cksum)

	SENDING="$RESPONSE $CKSUM"
	echo "Sending: $SENDING"
	echo "$SENDING"|nc -w 0 -u localhost $PORT
}


#SERVER->CLIENTE: 1 LINEAS CONTENTS+CKSUM
#Escritura al servidor
WEBPATH="/tmp/APIwebpage.html"
recv(){
	RESPONSE=$(nc -u -l $PORT | head -n 1)
	echo "response is $RESPONSE"
	REVCKSUM=$(echo "$RESPONSE" | rev | awk '{print $2}')
	echo "REVCK: $REVCKSUM"
	RESPONSE=$(echo ${RESPONSE} | sed 's/ [0-9]* [0-9]*$//')
	CKSUM=$(echo ${RESPONSE} | cksum | awk '{print $1}' | rev)

	if [ $CKSUM = $REVCKSUM ]
	then
		echo "CKSUM correcto"
		echo $RESPONSE  > $WEBPATH	
	else 

		echo "WARNING! CHECKSUM ERROR"  > $WEBPATH	
	fi 
}

#check correct usage
if [ $# -gt 0 ]
then

	echo -e "Error: Incorrect usage of client.sh\nUse: $0 and type the URL as input later"
	exit 1
fi

while [ 1 ]
do
	read -p "Enter a QUERY: " URI
	if [ $URI = "exit" ]
	then
		break
	fi
	send $URI
	recv
	#PID=$(pidof firefox)
	#kill -s SIGTERM $PID
	firefox  $WEBPATH &

done

echo "[+] Exited successfully"
exit 0



