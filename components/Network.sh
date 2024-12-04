  GNU nano 8.1                                                                                                                                                                            net2.sh                                                                                                                                                                                     #!/bin/bash
 echo -e "\e[1;34m Welcome to the Network Menu \e[0m"
 echo -e "\e[1;34m ____________________________ "
 echo -e "\e[1;34m Enter another Option Number | "
 echo -e "\e[1;34m ---------------------------- "
select options in ShowList Disable Enable SetIPaddress SelectNetwork Exit
        do
                case $options in
                ShowList)
                echo -e "\e[1;34m Network Cards :\n"
                ip link | grep  -e"mtu" -e"inet"
                echo -e "\e[1;34m \e[37m"
                echo -e "\e[1;34m ____________________________ "
                echo -e "\e[1;34m Enter another Option Number | "
                echo -e "\e[1;34m ---------------------------- "
                ;;
                Disable)
                echo -e "\e[1;34m Enter a Card Name \e[0m"
                echo -e " Net Cards : \e[0m"
                ip link |grep -e"mtu"|awk '{print NR,$2,$9}'
                echo " "
                echo "Enter card name"
                read name
                sudo ifconfig $name down 2> /dev/null
                read name
                 if [ $? -ne 0 ]
                then
                echo -e "\e[1;31m\n input is invalid \n\e[0m"
                else
                echo -e "\e[1;32m\n Task Complete \n\e[0m"
                fi
                echo -e "\e[1;34m ____________________________ "
                echo -e "\e[1;34m Enter another Option Number | "
                echo -e "\e[1;34m ---------------------------- "
                ;;
                Enable)
                echo -e "\e[1;34m Enter Card Name \e[0m"
                 echo -e " Net Cards : \e[0m"
                ip link |grep -e"mtu" |awk '{print NR,$2,$9}'
                 echo ""
                echo "Enter Card Name"
                read name
                sudo ifconfig $name up  2> /dev/null
                if [ $? -ne 0 ]
                then
                echo -e "\e[1;31m\n input is invalid \n\e[0m"
                else
                echo -e "\e[1;32m\n Task Complete \n\e[0m"
                fi
                echo -e "\e[1;34m ____________________________ "
                echo -e "\e[1;34m Enter another Option Number | "
                echo -e "\e[1;34m ---------------------------- "
                ;;
                SetIPaddress)
                echo -e "\e[1;34mEnter Net Card \e[0m"
                ip link |grep -e"mtu" |awk '/1/ -F ":" {print NR,$2,$9}'
                read Netcard
                echo -e "\e[1;34mEnter  an IPaddress \e[0m"
                read IP
                sudo ifconfig $Netcard $IP 2> /dev/null
                if [ $? -ne 0 ]
                then
                echo -e "\e[1;31m\n input is invalid \n\e[0m"
                else
                echo -e "\e[1;32m\n Task Complete \n\e[0m"
                fi
                echo -e "\e[1;34m ____________________________ "
                echo -e "\e[1;34m Enter another Option Number | "
                echo -e "\e[1;34m ---------------------------- "
                ;;
                SelectNetwork)
                echo -e "\e[1;34m List of networks \e[0m"
                sudo nmcli dev wifi |sort|uniq|awk '{print $2}'
                echo -e "\e[1;34m enter network"
                read netName
                echo -e "\e[1;34m enter password \e[0m"
                read pass
                sudo nmcli dev wifi connect $netName  password $pass 2> /dev/null
                if [ $? -ne 0 ]
                then
                echo -e "\e[1;31m\n input is invalid \n\e[0m"
                else
                echo -e "\e[1;32m\n Task Complete \n\e[0m"
                fi
                echo -e "\e[1;34m ____________________________ "
                echo -e "\e[1;34m Enter another Option Number | "
                echo -e "\e[1;34m ---------------------------- "
                ;;

                Exit)
                        echo -n -e "\e[0m"
                break
                ;;
         esac
Reply= echo -e "\e[1;34m1) ShowList\n2) Disable\n3) Enable\n4) SetIPaddress\n5) SelectNetwork\n6) Exit\e[0m "
done
