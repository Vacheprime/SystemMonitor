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
                1) return ;;                                            # Return to Main Menu
                2)	chmod +x systemStatus.sh
			./systemStatus.sh ;;                 		# System Status
                3) # Backup File
                4)	chmod +x Network.sh
			./Network.sh                                    # Network
                5) # System Services
                6) ./UserManagement.sh
                7) ./fileManagement.sh
                8) exit 0 ;;                                            # Exit the script
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
            2) exit 0 ;;          # Exit the script
            *) echo -e "${RED}Invalid option. Try again.${RESET}"; break ;;
        esac
    done
done
