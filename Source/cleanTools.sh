#!/bin/bash

# This simple script go through all directoy inside Source and removed all compiled tools

CLEAN_SHELL=./Clean.sh
COUNTER=0
for dir in $(find . -maxdepth 1 -type d); do 
	
	if [[ $COUNTER = 0 ]]; then
		COUNTER=1
	else 
		cd $dir
		$CLEAN_SHELL
		cd ..
	fi
done	
