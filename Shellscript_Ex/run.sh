#!/bin/bash
if [$# = 0]
then
    echo "Enter the container name"
    exit 1
fi

name=""
for name in $*;
do
    isOn=$(docker container ls -aq --filter "name=$name" )
    if [ $isOn -ne "" ]
    then
        echo "$name is already on"
        docker container rm -f $isOn
    fi
    echo "Create $name container"
    docker container run --name $name -dti zzid/zzidweb:latest /bin/bash
done
