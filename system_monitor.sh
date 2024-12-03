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
                1) # Return to Main Menu
		   return
		   ;;
                2) # System Status
		   chmod 770 systemStatus.sh;
		   ./systemStatus.sh;
		   break
		   ;;
                3) # Backup File
		   echo "Backup is being built...";
                   break
		   ;;
		4) # Network
		   chmod 770 Network.sh;
		   ./Network.sh;
		   break
		   ;;
                5) # System Services
		   echo "System Services are being built...";
                   break
		   ;;
		6) # User Management
		   chmod 770 UserManagement.sh
		   ./UserManagement.sh;
		   break
		   ;;
                7) # File management
		   chmod 770 fileManagement.sh
		   ./fileManagement.sh;
		   break
		   ;;
                8) # Exit the script
		   echo -e "${YELLOW} See you later, user!${RESET}"
		   exit 0;
		   ;;
                *) # Default
		   echo -e "${RED}Invalid option. Make sure you typed the number to the corresponding option that you'd like to choose${RESET}"
		   break
		   ;;
            esac
        done
    done
}

# start?
echo -e "${YELLOW}WELCOME TO OUR SYSTEM MONITOR!${RESET}"
# Main Menu
while true; do
    echo -e "\n${PURPLE}MAIN MENU${RESET}"
    echo -e "${CYAN}Choose an option: ${RESET}"
    options=("CMD1" "Exit")
    select option in "${options[@]}"; do
        case $REPLY in
            1) # Call the submenu
	       submenu;
	       break
	       ;;
            2) # Exit the program
	       echo -e "${YELLOW}See you later, user!${RESET}"
	       exit 0
	       ;;
            *) echo -e "${RED}Invalid option. Try again.${RESET}";
	       break
	       ;;
        esac
    done
done
