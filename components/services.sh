#!/bin/bash

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

PS3=$'\nSelect an option: '
select option in "Show Current Services" "Stop a Service" "Start a Service" "Go Back to Main Menu"
do
    case "$option" in 
	"Show Current Services")
	    # List all active services
	    systemctl list-units --state=active --type=service | less -S
	    ;;
	"Start a Service")
	    startService
	    ;;
	"Stop a Service")
	    stopService
	    ;;
	"Go Back to Main Menu")
	    exit 0
	    ;;
	*)
	    echo -e "\nPlease enter a valid option!"
	    ;;
    esac
    REPLY=
done
