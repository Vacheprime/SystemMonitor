#!/bin/bash

# This will will called inside other executable files that require the mutt command (if this is not installed already)
installMutt() {
   if  command -v mutt &> /dev/null; then
	echo "Mutt is already installed"
	# The program ran successfully:
	return 0;
   fi
	echo "Mutt is not installed. Attempting to install it..."
   if command -v apt &>/dev/null; then
		sudo apt update

	if sudo apt install -y mutt; then
		echo "Mutt has been installed successfully"
		return 0
	else
		echo "Error failed to install mutt"
		return 1

	fi

   else
	echo "Error: This script supports only Debian/Ubuntu systems"
	return 1
   fi
}

installMutt
