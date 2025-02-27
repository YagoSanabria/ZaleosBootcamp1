#!/bin/bash

#Escritura al servidor
echo -e "REQUEST" | nc -w 0 -u localhost 8080
echo "$(nc -u -l 8080 | head -n 1)" > /tmp/APIwebpage.txt

firefox /tmp/APIwebpage.txt &





