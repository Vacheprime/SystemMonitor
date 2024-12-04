#!/bin/bash

# Function to check if a command exists, and install it if not
check_and_install_command() {
  command_name=$1

   # Ensure a command name is provided
   if [ -z "$command_name" ]; then
   	echo "Error: No command specified. Usage: $0 <command_name>"
   	exit 1
   fi

   # Check if the command is already installed
   if command -v "$command_name" &>/dev/null; then
   	echo "The command '$command_name' is already installed."
	exit 0
   fi

	echo "The command '$command_name' is not installed. Installing it now..."

   # Make sure the package is available
   if ! command -v apt &>/dev/nul; then
	echo "Error: This script requires the 'apt' package."
	exit 1
   fi

   # Check when the package list was last updated
   cache_file="/var/cache/apt/pkgcache.bin"
   if [ ! -f "$cache_file" ] || [ $(( $(date +%s) - $(stat -c %Y "$cache_file") )) -gt 86400 ]; then
    	echo "Updating package list..."
    	sudo apt update -y
   else
	echo "Package list is up-to-date."
   fi

   # Install the command
   sudo apt install -y "$command_name"

   # Verify if the installation was successful
   if command -v "$command_name" &>/dev/null; then
   	echo "'$command_name' has been successfully installed."
	exit 0
   else
	echo "Error: Failed to install '$command_name'. Please check your permissions."
   	exit 1
   fi
}

# Main script logic
if [ -z "$1" ]; then
   echo "Usage: $0 <command_name>"
   exit 1
fi

# Call the function with the provided command name
check_and_install_command "$1"
