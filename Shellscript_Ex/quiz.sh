#!/bin/bash

randNum=$(rand)
count=0
echo $randNum

while((1))
do
    echo "Your answer?"
    read ans
    if [ $ans -gt $randNum ]
    then
        echo "Down"
    elif [ $ans -lt $randNum ]
    then
        echo "Up"
    else
        echo "Correct!"
        exit 0
    fi
done
exit 0