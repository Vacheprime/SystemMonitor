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
    echo -e "\nAll active services: \n"
    # Get all active services
    allServices=$(systemctl list-units --state=active --type=service --quiet | # list all active services
	awk '$2 == "loaded" {print $1}' | # Select only those that are loaded and can be stopped 
	sed "s/.service//" # Remove trailing .service
    )
    # Display  the services as columns
    echo -e "$allServices" | column
    echo ""

    read -p "Enter a service to stop: " service
    if ! echo "$allServices" | grep -P "^$service$" &> /dev/null; then
	echo -e "\nYou must enter a service from the list of inactive services!\n"
	return 1
    fi
    if sudo systemctl stop "$service"; then
	echo -e "\nService '$service' stopped!"
    else
	echo -e "\nCould not stop service '$service'!"
    fi
    echo ""
}

# Start a service
startService() {
    echo -e "\nAll inactive services: \n"
    # Get all inactive services
    allServices=$(systemctl list-units --state=inactive --type=service --quiet | # list all inactive services
	awk '$2 == "loaded" {print $1}' | # Select only those that are loaded and can be enabled
	sed "s/.service//" # Remove trailing .service
    )
    # Display  the services as columns
    echo -e "$allServices" | column
    echo ""

    read -p "Enter a service to start: " service
    if ! echo "$allServices" | grep -P "^$service$" &> /dev/null; then
	echo -e "\nYou must enter a service from the list of active services!\n"
	return 1
    fi
    if sudo systemctl start "$service"; then
	echo -e "\nService '$service' started!"
    else
	echo -e "\nCould not start service '$service'!"
    fi
    echo ""
}

echo -e "SERVICE MANAGEMENT\n"
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
	    startService
	    ;;
	"${options[2]}")
	    stopService
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
