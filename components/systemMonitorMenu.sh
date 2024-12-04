#!/bin/bash

# Define some color codes for easier use
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
PURPLE='\e[35m'
CYAN='\e[36m'
RESET='\e[0m'

# Function for CMD1 Submenu
submenu() {
    while true; do
        echo -e "\n${GREEN}CMD1 SUBMENU${RESET}"
        echo -e "${CYAN}Choose an option: ${RESET}"
        options=("Go Back to Main Menu" "System Status" "Backup" "Network" "Services" "User Management" "File Management" "Exit")
        select option in "${options[@]}"; do
            case $REPLY in
                "Go back to Main Menu")
		   return
		   ;;
		"System Status")
		   chmod 770 systemStatus.sh
		   ./systemStatus.sh
		   break
		   ;;
		"Backup")
		   chmod 770 backup.sh
		   ./backup.sh
		   break
		   ;;
		"Network")
		   chmod 770 Network.sh
		   ./Network.sh
		   break
		   ;;
		"Services")
		   chmod 770 services.sh
		   ./services.sh
		   break
		   ;;
		"User Management")
   		   chmod 770 UserManagement.sh
		   ./UserManagement.sh
		   break
		   ;;
		"File Management")
		   chmod 770 fileManagement.sh
		   ./fileManagement.sh
		   break
		   ;;
                "Exit") exit 0
		   ;;
                *) echo -e "${RED}Invalid option. Try again.${RESET}"; break ;;
            esac
        done
    done
}

# Main Menu
while true; do
    echo -e "\n${PURPLE}MAIN MENU${RESET}"
    echo -e "${CYAN}Choose an option: ${RESET}"
    options=("CMD1" "Exit")
    select option in "${options[@]}"; do
        case $REPLY in
            1) submenu; break ;;  # Call CMD1 Submenu
            2) exit 0 ;;  	  # Exit the script
            *) echo -e "${RED}Invalid option. Try again.${RESET}"; break ;;
        esac
    done
done
