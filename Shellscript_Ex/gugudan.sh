#!/bin/bash

for i in {1..9}
do
    for j in $(seq 2 9)
    do
        printf "%s x %s = %s\t" $j $i `expr $i \* $j`
        if [ $j = 9 ]
        then
                printf "\n"
        fi
    done
done

exit 0
