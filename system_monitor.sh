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
mainMenu() {
	echo -e "\n${GREEN}MAIN MENU${RESET}\n"
	
	# Color the prompt
	PS3=$(echo -e "\n${CYAN}Choose an option: ${RESET}")
	# Color the options
	options=(
		"$(echo -e "${YELLOW}System Status Information${RESET}")"
		"$(echo -e "${YELLOW}Backup Management${RESET}")"
		"$(echo -e "${YELLOW}Network Management${RESET}")"
		"$(echo -e "${YELLOW}Service Management${RESET}")"
		"$(echo -e "${YELLOW}User Management${RESET}")"
		"$(echo -e "${YELLOW}File Management${RESET}")"
		"$(echo -e "${YELLOW}Exit${RESET}")"
	)
	select option in "${options[@]}"; do
		case "$option" in
			"${options[0]}") # System Status
				echo "" 
				bash components/systemStatus.sh
				;;
			"${options[1]}") # Backup File
				echo "" 
				bash components/backup.sh
				;;
			"${options[2]}") # Network
				echo "" 
				bash components/Network.sh
				;;
			"${options[3]}") # System Services
				echo "" 
				bash components/services.sh
				;;
			"${options[4]}") # User Management
				echo "" 
				bash components/UserManagement.sh;
				;;
			"${options[5]}") # File management
				echo "" 
				bash components/fileManagement.sh;
				;;
			"${options[6]}") # Exit the script
				echo -e "\n${YELLOW}See you later, user!${RESET}"
				exit 0;
				;;
			*) # Default
				echo -e "\n${RED}Invalid option. Make sure you typed the number to the corresponding option that you'd like to choose!${RESET}\n"
				;;
		esac
		# Reprint the menu
		REPLY=
	done
}

# start?
echo -e "${PURPLE}WELCOME TO OUR SYSTEM MONITOR!${RESET}"
mainMenu
