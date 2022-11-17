#! /bin/bash
if [[ -d /tmp ]];
then
    echo "$DIR directory exists."
else
	echo "$DIR directory does not exist."
fi

#https://stackoverflow.com/questions/3427872/whats-the-difference-between-and-in-bash