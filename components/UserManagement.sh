#!/bin/bash

select option in addUser giveRootPermission deleteUser showUsers disconnectUser showUserGroups changeUserGroups Exit
do

        case $option in
        addUser)
        echo "enter Username"
        read name
        sudo useradd  $name 2> /dev/null
        echo "enter User password"
        sudo passwd $name
        if [ $? -ne 0 ]
        then
        echo "input was invalid"
        else
        echo "User $name has been added"
        fi
        ;;
        giveRootPermission)
        echo "Enter Username"
        read name
        $name ALL=(ALL:ALL)ALL
        ;;
        deleteUser)
        echo "Enter Username"
        read name
        sudo userdel -f $name 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo "input was invalid"
        else
        echo "User $name has been deleted"
        fi
        ;;

        showUsers)
        who|awk '{print $1}'
        ;;

        disconnectUser)
        who -u
        echo "Enter user code"
        read code
        kill $code 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo "input was invalid"
        else
        echo "User has been disconnected"
        fi
        ;;
        changeUserGroups)
        echo "Enter the current Group"
        read group1
        echo "Enter the new Group"
        read group2
        sudo groupmod $group1  $group2 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo "input was invalid"
        else
        echo " $group1 groups have been changed"
        fi

        ;;
        Exit)
        break
        ;;

        esac
done


