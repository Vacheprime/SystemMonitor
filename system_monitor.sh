#!/bin/bash

# Define a list of options the user can chose from
options=("System Status" "Backup" "Network" "Services" "User Management" "File Management" "Exit")

# Create a menu containing all of the options from the options variable
select option in "${options[@]}"
do
	# Check which option the user chose
	case option in
		"System Status")
			# Execute system status script
			# Example: bash components/test.sh
			;;
		"Backup")
			# Execute backup script
			;;
		"Network")
			# Execute network script
			;;
		"Services")
			# Execute services script
			;;
		"User Management")
			# Execute user management script
			;;
		"File Management")
			# Execute file management script
			;;
		*)
			# Default statement code
			;;
	esac
done
