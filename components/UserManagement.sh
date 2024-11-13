#!/bin/bash

select option in addUser giveRootPermission deleteUser showUsers disconnectUser showUserGroups changeUserGroups Exit
do

	case $option in
	addUser)
	echo "enter Username"
	read name
	echo "enter User password"
	read password
	sudo useradd -p $password $name
	echo "User $name has been added"
	;;

	giveRootPermission)
	echo "Enter Username"
	read name
	sudo usermod -aG root $name
	;;

	deleteUser)
	echo "Enter Username"
	read name
	sudo userdel -f $name
	echo "User $name has been deleted"
	;;

	showUsers)
	who|awk '{print $1}'
	;;

	disconnectUser)
	who -u
	echo "Enter user code"
	read code
	kill $code
	;;

	showUserGroups)
	echo "Enter Username"
	read name
	sudo groups $name
	;;

	changeUserGroups)
	echo "Enter Username"
        read name
        echo "Enter the current Group"
        read group1
	echo "Enter the new Group"
	read group2
	sudo groupmod $group1  $group2
	;;
	Exit)
	break
	;;

	esac
done
