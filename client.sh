#!/bin/bash

# ! Warning 
#Version of netcat needed: OpenBSD metcat (Debian patchlevel 1.226-1ubuntu2)
#If not, wrong behaviour of netcat can occur

PORT=8080

#CLIENT->SERVER: 1 LINE: CONTENTS+CKSUM divided by columns
function send(){	#$1 arg = sendInfo
	RESPONSE=$1
    CKSUM=$(echo "$RESPONSE" | cksum)
	SENDING="$RESPONSE $CKSUM"
	echo "Sending: $SENDING"
	echo "$SENDING"|nc -w 0 -u localhost $PORT
}

#SERVER->CLIENT: 1 LINE CONTENTS+CKSUM
WEBPATH="/tmp/APIwebpage.html" #temporal local file path
recv(){
	RESPONSE=$(nc -u -l $PORT | head -n 1)
	echo "response is $RESPONSE"
	REVCKSUM=$(echo "$RESPONSE" | rev | awk '{print $2}')
	#analize checksum reversed to get last bytes of msg ignoring msg length
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

#client loop
while [ 1 ]
do
	read -p "Enter a QUERY: ("exit" to finish)" URI
	if [ $URI = "exit" ]
	then
		break
	fi
	send $URI
	recv
	firefox  $WEBPATH &

done
#exit
echo "[+] Exited successfully"
exit 0