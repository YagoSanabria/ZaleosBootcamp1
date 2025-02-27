#!/bin/bash

#Escritura al servidor
echo -e "$1" | nc -w 0 -u localhost 8080
echo "$(nc -u -l 8080 | head -n 1)" > /tmp/APIwebpage.html

firefox /tmp/APIwebpage.html &
exit 0



