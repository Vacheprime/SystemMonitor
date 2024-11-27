#!/bin/bash

# Function to check if a command exists, and install it if not
check_and_install_command() {
  command_name=$1

   # Check if the command is installed
   if ! command -v "$command_name" &>/dev/null; then
	 echo "The command '$command_name' is not installed. Installing it now..."

   # Update the package list and install the command
   sudo apt update && sudo apt install -y "$command_name"

   # Check if the installation was successful
   	if command -v "$command_name" &>/dev/null; then
		echo "'$command_name' has been successfully installed."
   	else
		echo "Failed to install '$command_name'. Please check your permissions."
   	fi
  else
    	echo "The command '$command_name' is already installed."
  fi
}

   # Check if the user provided a command to check
   if [ -z "$1" ]; then
	echo "Usage: $0 <command_name>"
  	exit 1
   fi

   # Call the function with the command name
   check_and_install_command "$1"
