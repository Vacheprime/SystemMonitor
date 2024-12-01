#!/bin/bash

# Backup Functions

# Helper method used to validate the day of the month param
function validateMonthDay() {
	# Based on the month number
	case $1 in
		1)
			if [[ $2 -gt 31 ]]; then
				return 1
			fi
			;;
		2)
			if [[ $2 -gt 29 ]]; then
				return 1
			fi
			;;
		3)
			if [[ $2 -gt 31 ]]; then
				return 1
			fi
			;;
		4)
			if [[ $2 -gt 30 ]]; then
				return 1
			fi
			;;
		5)
			if [[ $2 -gt 31 ]]; then
				return 1
			fi
			;;
		6)
			if [[ $2 -gt 30 ]]; then
				return 1
			fi
			;;
		7)
			if [[ $2 -gt 31 ]]; then
				return 1
			fi
			;;
		8)
			if [[ $2 -gt 31 ]]; then
				return 1
			fi
			;;
		9)
			if [[ $2 -gt 30 ]]; then
				return 1
			fi
			;;
		10)
			if [[ $2 -gt 31 ]]; then
				return 1
			fi
			;;
		11)
			if [[ $2 -gt 30 ]]; then
				return 1
			fi
			;;
		12)
			if [[ $2 -gt 31 ]]; then
				return 1
			fi
			;;
	esac
}

# Create a new backup schedule 
function CreateNewBackupSchedule() {
	# Get all of the required user input
	echo -e "\n--- File and Backup Folder Paths ---\n"
	echo -e -n "\tEnter the absolute file path of file to backup: "
	read absFilePath

	echo -e -n "\tEnter the absolute folder path of the backup destination: "
	read absFolderPath

	echo -e "\n--- Schedule Date and Time ---\n"
	echo -e -n "\tEnter the hour at which to backup (0 - 23 or * for every hour): "
	read hour

	echo -e -n "\tEnter the minute at which to backup (0 - 59 or * for every minute): "
	read minute

	echo -e -n "\tEnter the month at which to backup (1 - 12 or * for every month): "
	read month

	echo -e -n "\tEnter the day of the month at which to backup (1 - 31 or * for every day of the month): "
	read monthDay

	echo -e -n "\tEnter the day of the week at which to backup (0 - 7, 0 and 7 are Sunday or * for every week day): "
	read weekDay

	# Validate the file path of the file to backup
	if ! [[ "$absFilePath" =~ ^/ ]]; then
		echo -e "\nThe file path must be an absolute file path!\n"
		return 1
	elif ! [[ -f "$absFilePath" ]]; then
		echo -e "\nThe file to backup specified does not exist!\n"
		return 1
	fi

	# Validate the folder path 
	if ! [[ "$absFolderPath" =~ ^/ ]]; then
		echo -e "\nThe folder path must be an absolute folder path!\n"
		return 1
	elif ! [[ -d "$absFolderPath" ]]; then
		echo -e -n "\nThe folder specified does not exist!\n"
		return 1
	fi

	# Validate the hour
	if ! [[ "$hour" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\nYou must enter a number for the hour!\n"
		return 1
	elif [[ "$hour" != "*" ]]; then
		if [[ $hour -lt 0 || $hour -gt 23 ]]; then
			echo -e "\nThe hour must be between 0 and 23!\n"
			return 1
		fi
	fi

	# Validate the minute
	if ! [[ "$minute" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\nYou must enter a number for the minute!\n"
		return 1
	elif [[ "$minute" != "*" ]]; then
		if [[ $minute -lt 0 || $minute -gt 59 ]]; then
			echo -e "\nThe minute must be between 0 and 59!\n"
			return 1
		fi
	fi

	# Validate the month
	if ! [[ "$month" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\nYou must enter a number for the month!\n"
		return 1
	elif [[ "$month" != "*" ]]; then
		if [[ $month -lt 1 || $month -gt 12 ]]; then
			echo -e "\nThe month must be between 1 and 12!\n"
			return 1
		fi
	fi

	# Validate the week day
	if ! [[ "$weekDay" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\nYou must enter a number for the week day!\n"
		return 1
	elif [[ "$weekDay" != "*" ]]; then
		if [[ $weekDay -lt 0 || $weekDay -gt 7 ]]; then
			echo -e "\nThe week day must be between 0 and 7!\n"
			return 1
		fi
	fi

	# Validate the month day
	if ! [[ "$monthDay" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\nYou must enter a number for the month day!\n"
		return 1
	elif [[ "$weekDay" != "*" ]]; then
		if [[ $monthDay -lt 1 ]]; then
			echo -e "\nThe month day must be between 0 and 31!\n"
			return 1
		elif ! validateMonthDay $month $monthDay; then
			echo -e "\nThe month day is invalid for the month specified!\n"
			return 1
		fi
	fi

	# Check if user has write permissions
	if [[ -w "$absFilePath" && -w "$absFolderPath" ]]; then
		((crontab -l; echo "$minute $hour $monthDay $month $weekDay rsync -cLUtp \"$absFilePath\" \"$absFolderPath\"") | crontab -) &> /dev/null
		# Check if it executed successfully
		if [[ $? -eq 1 ]]; then
			echo -e "\nFailed to create the backup scheduled!\n"
			return 1
		fi
	else
		echo "The current user does not have permission to write to the file and the folder."
		read -p "Would you like to schedule backup on the root account's scheduler? [y/n]: " doTry
		if [ "$doTry" != "y" ]; then
			echo -e "The operation has been cancelled!\n"
			return 1
		fi
		# Add the backup job to the root's crontab
		((sudo crontab -l; echo "$minute $hour $monthDay $month $weekDay rsync -cLUtp \"$absFilePath\" \"$absFolderPath\"") | crontab -) &> /dev/null
		# Check if it executed successfully
		if [[ $? -eq 1 ]]; then
			echo -e "\nFailed to create the backup scheduled!\n"
			return 1
		fi
	fi
	echo -e "\nSuccessfully added backup schedule!\n"
}


# Main Loop
# Define the list of available options
options=("Create New Backup Schedule" "Display Current Backup Schedules" "Display Last Backup Processes" "Go Back to Main Menu")

# Customise the input prompt
PS3=$'\nPlease select an option: '

# Print a menu containing all available options
select option in "${options[@]}"; 
do
	case $option in
		"Create New Backup Schedule")
			CreateNewBackupSchedule
			;;
		"Display Current Backup Schedule")
			;;
		"Display Last Backup Process")
			;;
		"Go Back to Main Menu")
			exit 0
			;;
		*)
			echo -e "\nInvalid Option!"
			;;
	esac
	REPLY=
done
