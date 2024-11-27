#!/bin/bash
echo "select an opiton"
select options in ShowList Disable Enable SetIPaddress SelectNetwork Exit
        do
                case $options in
                ShowList)
                ifconfig | grep  -e"mtu" -e"inet"
                ;;
                Disable)
                echo "enter card name "
                read name
                sudo ifconfig $name down 2> /dev/null
                 if [ $? -ne 0 ]
                then
                echo "input is invalid"
                fi
                ;;
                Enable)
                echo "enter card name"
                read name
                sudo ifconfig $name up  2> /dev/null
                if [ $? -ne 0 ]
                then
                echo "input is invalid"
                fi
                ;;
                SetIPaddress)
                echo "enter  an IPaddress "
                read IP
                echo "enter Net Card"
                read Netcard
                sudo ifconfig $Netcard $IP 2> /dev/null
                if [ $? -ne 0 ]
                then
                echo "input are invalid"
                fi
                ;;
                SelectNetwork)
                echo "List of networks"
                nmcli dev wifi | awk '{print $2}'> networks.txt
                uniq -u networks.txt
                echo "enter network"
                read netName
                echo "enter password"
                read pass
                nmcli dev wifi connect $netName  password $pass 2> /dev/null
                if [ $? -ne 0 ]
                then
                echo "input are invalid"
                fi
                ;;

                Exit)
                break
                ;;
        esac
done
