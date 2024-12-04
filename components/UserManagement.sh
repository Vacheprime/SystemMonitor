#!/bin/bash
        echo -e "\e[1;34m Welcome to the User Management App "
select option in addUser giveRootPermission deleteUser showUsers disconnectUser showUserGroups changeUserGroups Exit
do

        case $option in
        addUser)
        echo -e "\e[1;37menter Username: \e[0m"
        read name
        sudo useradd  $name 2> /dev/null
        echo "enter User password twice: "
        sudo passwd $name 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo -e "\e[1;31m\n input was invalid \n\e[0m"
        else
        echo -e "\e[1;32m\n User $name has been added \n\e[0m"
        fi
        echo -e "\e[1;34m ____________________________ "
        echo -e "\e[1;34m |Enter another Option Number | "
        echo -e "\e[1;34m ---------------------------- \n"
        ;;
        giveRootPermission)
        echo -e "\e[1;37m\nEnter Username"
        read name
        sudo usermod -a -G root $name 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo -e "\e[1;31m\n input was invalid \n\e[0m"
        else
        echo -e "\e[1;32m\n User $name has been given root permissons \n\e[0m"
        fi
        echo -e "\e[1;34m ____________________________"
        echo -e "\e[1;34m |Enter another Option Number |"
        echo -e "\e[1;34m ----------------------------\n"
	;;
        deleteUser)
        echo "Enter Username"
        read name
        sudo userdel -f $name 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo -e "\e[1;31m\n input was invalid \n\e[0m"
        else
        echo -e "\e[1;32m\n User $name has been removed \n\e[0m"
        fi
        echo -e "\e[1;34m ____________________________ "
        echo -e "\e[1;34m |Enter another Option Number | "
        echo -e "\e[1;34m ----------------------------\n"
	;;

        showUsers)
        echo -e "\e[1;37m"
        who|awk '{print $1}'
        echo -e "\e[1;34m ___________________________"
        echo -e "\e[1;34m |Enter another Option Number|"
        echo -e "\e[1;34m ---------------------------\n"
        ;;
        disconnectUser)
        who -u
        echo "Enter user code"
        read code
        kill $code 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo -e "\e[1;31m\n input was invalid \n\e[0m"
        else
        echo -e "\e[1;32m\n User $name has been disconnected  \n\e[0m"
        fi
        echo -e "\e[1;34m ___________________________"
        echo -e "\e[1;34m |Enter another Option Number|"
        echo -e "\e[1;34m ---------------------------\n"
        ;;
        changeUserGroups)
        echo "Enter the current Group"
        read group1
        echo "Enter the new Group"
        read group2
        sudo groupmod $group1  $group2 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo -e "\e[1;31m\n input was invalid \n\e[0m"
        else
        echo -e "\e[1;32m\n User $name group has beem changed  \n\e[0m"
        fi
        echo -e "\e[1;34m ___________________________"
        echo -e "\e[1;34m |Enter another Option Number|"
        echo -e "\e[1;34m ---------------------------\n"
        ;;
        disconnectUser)
        who -u
        echo "Enter user code"
 read code
        kill $code 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo -e "\e[1;31m\n input was invalid \n\e[0m"
        else
        echo -e "\e[1;32m\n User $name has been disconnected  \n\e[0m"
        fi
        echo -e "\e[1;34m ___________________________"
        echo -e "\e[1;34m |Enter another Option Number|"
        echo -e "\e[1;34m ---------------------------\n"
	;;
        changeUserGroups)
        echo "Enter the current Group"
        read group1 echo "Enter the new Group"
        read group2
        sudo groupmod $group1  $group2 2> /dev/null
        if [ $? -ne 0 ]
        then
        echo -e "\e[1;31m\n input was invalid \n\e[0m"
        else
        echo -e "\e[1;32m\n User $name group has beem changed  \n\e[0m"
        fi
        echo -e "\e[1;34m ___________________________"
        echo -e "\e[1;34m |Enter another Option Number|"
        echo -e "\e[1;34m ---------------------------\n"
	;;
        Exit)
        break
           ;;

        esac
	REPLY=
done

