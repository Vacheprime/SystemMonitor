#!/bin/bash

## COLOR CONSTANTS
RED='\e[31m'
GREEN='\e[32m'
YELLOW='\e[33m'
BLUE='\e[34m'
PURPLE='\e[35m'
CYAN='\e[36m'
RESET='\e[0m'
##

# Stop a service
function stopService() {
    echo -e "\n${PURPLE}All active services: ${RESET}\n"
    # Get all active services
    allServices=$(systemctl list-units --state=active --type=service --quiet | # list all active services
	awk '$2 == "loaded" {print $1}' | # Select only those that are loaded and can be stopped 
	sed "s/.service//" # Remove trailing .service
    )
    # Display  the services as columns
    echo -e -n "${GREEN}"
    echo "$allServices}" | column
    echo -e -n "${RESET}"

    echo -e -n "\n${CYAN}Enter a service to stop: ${RESET}"
    read service

    if ! echo "$allServices" | grep -P "^$service$" &> /dev/null; then
	echo -e "\n${RED}You must enter a service from the list of active services!${RESET}\n"
	return 1
    fi
    if sudo systemctl stop "$service"; then
	echo -e "\n${GREEN}Service '$service' stopped!${RESET}"
    else
	echo -e "\n${RED}Could not stop service '$service'${RESET}!"
    fi
    echo ""
}

# Start a service
startService() {
    echo -e "\n${PURPLE}All inactive services: ${RESET}\n"
    # Get all inactive services
    allServices=$(systemctl list-units --state=inactive --type=service --quiet | # list all inactive services
	awk '$2 == "loaded" {print $1}' | # Select only those that are loaded and can be enabled
	sed "s/.service//" # Remove trailing .service
    )
    # Display  the services as columns
    echo -e -n "${GREEN}"
    echo -e "$allServices" | column
    echo -e -n "${RESET}"

    echo -e -n "\n${CYAN}Enter a service to start: ${RESET}"
    read service
    if ! echo "$allServices" | grep -P "^$service$" &> /dev/null; then
	echo -e "\n${RED}You must enter a service from the list of inactive services!${RESET}\n"
	return 1
    fi
    if sudo systemctl start "$service"; then
	echo -e "\n${GREEN}Service '$service' started!${RESET}"
    else
	echo -e "\n${RED}Could not start service '$service'!${RESET}"
    fi
    echo ""
}

echo -e "${PURPLE}SERVICE MANAGEMENT${RESET}\n"
options=(
    "$(echo -e "${YELLOW}Show Current Services${RESET}")"
    "$(echo -e "${YELLOW}Stop a Service${RESET}")"
    "$(echo -e "${YELLOW}Start a Service${RESET}")"
    "$(echo -e "${YELLOW}Go Back to Main Menu${RESET}")"
)
prompt=$(echo -e -n "\n${CYAN}Select an option: ${RESET}")
PS3="$prompt"
select option in "${options[@]}"
do
    case "$option" in 
	"${options[0]}")
	    # List all active services
	    systemctl list-units --state=active --type=service | less -S -R
	    ;;
	"${options[1]}")
	    stopService
	    ;;
	"${options[2]}")
	    startService
	    ;;
	"${options[3]}")
	    exit 0
	    ;;
	*)
	    echo -e "\nPlease enter a valid option!"
	    ;;
    esac
    REPLY=
done
