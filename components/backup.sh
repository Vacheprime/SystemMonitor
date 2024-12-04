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
function createNewBackupSchedule() {
	# Get all of the required user input
	echo -e "\n${PURPLE}--- File and Backup Folder Paths ---${RESET}\n"
	echo -e -n "\t${CYAN}Enter the absolute file path of file to backup: ${RESET}"
	read absFilePath

	echo -e -n "\t${CYAN}Enter the absolute folder path of the backup destination: ${RESET}"
	read absFolderPath

	echo -e "\n${PURPLE}--- Schedule Date and Time ---${RESET}\n"
	echo -e -n "\t${CYAN}Enter the hour at which to backup (0 - 23 or * for every hour): ${RESET}"
	read hour

	echo -e -n "\t${CYAN}Enter the minute at which to backup (0 - 59 or * for every minute): ${RESET}"
	read minute

	echo -e -n "\t${CYAN}Enter the month at which to backup (1 - 12 or * for every month): ${RESET}"
	read month

	echo -e -n "\t${CYAN}Enter the day of the month at which to backup (1 - 31 or * for every day of the month): ${RESET}"
	read monthDay

	echo -e -n "\t${CYAN}Enter the day of the week at which to backup (0 - 7, 0 and 7 are Sunday or * for every week day): ${RESET}"
	read weekDay

	# Validate the file path of the file to backup
	if ! [[ "$absFilePath" =~ ^/ ]]; then
		echo -e "\n${RED}The file path must be an absolute file path!${RESET}\n"
		return 1
	elif ! [[ -f "$absFilePath" ]]; then
		echo -e "\n${RED}The file to backup specified does not exist!${RESET}\n"
		return 1
	fi

	# Validate the folder path 
	if ! [[ "$absFolderPath" =~ ^/ ]]; then
		echo -e "\n${RED}The folder path must be an absolute folder path!${RESET}\n"
		return 1
	elif ! [[ -d "$absFolderPath" ]]; then
		echo -e -n "\n${RED}The folder specified does not exist!${RESET}\n"
		return 1
	fi

	# Format the folder path
	if ! [[ "$absFolderPath" =~ /$ ]]; then
		absFolderPath+="/"
	fi

	# Validate the hour
	if ! [[ "$hour" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\n${RED}You must enter a number for the hour!${RESET}\n"
		return 1
	elif [[ "$hour" != "*" ]]; then
		if [[ $hour -lt 0 || $hour -gt 23 ]]; then
			echo -e "\n${RED}The hour must be between 0 and 23!${RESET}\n"
			return 1
		fi
	fi

	# Validate the minute
	if ! [[ "$minute" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\n${RED}You must enter a number for the minute!${RESET}\n"
		return 1
	elif [[ "$minute" != "*" ]]; then
		if [[ $minute -lt 0 || $minute -gt 59 ]]; then
			echo -e "\n${RED}The minute must be between 0 and 59!${RESET}\n"
			return 1
		fi
	fi

	# Validate the month
	if ! [[ "$month" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\n${RED}You must enter a number for the month!${RESET}\n"
		return 1
	elif [[ "$month" != "*" ]]; then
		if [[ $month -lt 1 || $month -gt 12 ]]; then
			echo -e "\n${RED}The month must be between 1 and 12!${RESET}\n"
			return 1
		fi
	fi

	# Validate the week day
	if ! [[ "$weekDay" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\n${RED}You must enter a number for the week day!${RESET}\n"
		return 1
	elif [[ "$weekDay" != "*" ]]; then
		if [[ $weekDay -lt 0 || $weekDay -gt 7 ]]; then
			echo -e "\n${RED}The week day must be between 0 and 7!${RESET}\n"
			return 1
		fi
	fi

	# Validate the month day
	if ! [[ "$monthDay" =~ ^[0-9]+$|^\*$ ]]; then
		echo -e "\n${RED}You must enter a number for the month day!${RESET}\n"
		return 1
	elif [[ "$weekDay" != "*" ]]; then
		if [[ $monthDay -lt 1 ]]; then
			echo -e "\n${RED}The month day must be between 0 and 31!${RESET}\n"
			return 1
		elif ! validateMonthDay $month $monthDay; then
			echo -e "\n${RED}The month day is invalid for the month specified!${RESET}\n"
			return 1
		fi
	fi
	# The rsync command is required to do incremental backups and 
	# must be installed
	echo ""
	if ! bash components/installCommand.sh "rsync"; then
	    echo -e "\n${RED}Could not install the 'rsync' command!${RESET}\n"
	    return 1
	fi

	# Check if user has write permissions
	if [[ -w "$absFilePath" && -w "$absFolderPath" ]]; then
		((crontab -l; echo "$minute $hour $monthDay $month $weekDay echo \"SYSBACKUP\" &> /dev/null; rsync -cLUp \"$absFilePath\" \"$absFolderPath\"") | crontab -) &> /dev/null
		# Check if it executed successfully
		if [[ $? -eq 1 ]]; then
			echo -e "\n${RED}Failed to create the backup scheduled!${RESET}\n"
			return 1
		fi
	else
		echo -e "${YELLOW}The current user does not have permission to write to the file and the folder."
		echo -e -n "Would you like to schedule backup on the root account's scheduler?${RESET} [${GREEN}y${RESET}/${RED}n${RESET}]: "
		read doTry
		if [ "$doTry" != "y" ]; then
			echo -e "${YELLOW}The operation has been cancelled!${RESET}\n"
			return 1
		fi
		# Add the backup job to the root's crontab
		((sudo crontab -l; sudo echo "$minute $hour $monthDay $month $weekDay echo \"SYSBACKUP\" &> /dev/null; rsync -cLUp \"$absFilePath\" \"$absFolderPath\"") | sudo crontab -) &> /dev/null
		# Check if it executed successfully
		if [[ $? -eq 1 ]]; then
			echo -e "\n${RED}Failed to create the backup scheduled!${RESET}\n"
			return 1
		fi
	fi
	echo -e "\n${GREEN}Successfully added backup schedule!${RESET}\n"
}

# Display the current backup schedules created by the system
function displayCurrentBackupSchedules() {
	echo -e "\n${PURPLE}VIEWING BACKUP SCHEDULES${RESET}\n"
	# Get the backup schedules for this user
	userSchedules=$(
		crontab -l |
		grep "SYSBACKUP"
	)

	# Prompt the user if he wants to see root backups
	echo -e "${YELLOW}The current user does not have the privileges to view root backup schedules."
	echo -e -n "Would you like to view backup schedules of the root account?${RESET} [${GREEN}y${RESET}/${RED}n${RESET}]: "
	read doTry
	if [ "$doTry" == "y" ]; then
		# Get the backup schedules created as root
		rootSchedules=$(sudo crontab -l 2>&1)
		# Check if command executed successfully
		if [ $? -eq 0 ]; then
			rootSchedules=$(echo "$rootSchedules" | grep "SYSBACKUP")

			# Get the backup folders 
			backupFolders=$(
			echo "$rootSchedules" |
				cut -f13 -d" " |
				sed "s/\"//g"
			)
			# Get the backup filenames
			backupFiles=$(
			echo "$rootSchedules" |
				cut -f12 -d" " |
				grep -Po "[^/]+\"$" | 
				sed "s/\"//g"
			)
			# Combine the paths of folder and file
			backupFiles=$(paste <(echo "$backupFolders") <(echo "$backupFiles") -d "")

			# Get the last modification time of the backup files
			backupTimes=""
			for file in $backupFiles
			do
				time=$(sudo stat --format='%y' "$file" 2>&1)
				if [ $? -ne 0 ]; then
					backupTimes+="Never."
				else
					backupTimes+=$(echo "$time" | cut -d" " -f1)
				fi
				backupTimes+=$'\n'
			done

			# Remove the trailing newline
			backupTimes=$(echo -n "$backupTimes")

			# Combine the dates to the root schedule strings so its accessible
			# via awk
			rootSchedules=$(paste <(echo "$rootSchedules") <(echo "$backupTimes") -d" " 2> /dev/null)

			# Print the root schedules
			echo "$rootSchedules" | awk '{ printf "\n\033[36m(\033[31mRoot\033[36m) Schedule \033[32m%d\033[36m:\nFile to backup: \033[33m%s\n\033[36mBackup Location: \033[33m%s\n\033[36mLast backup time: \033[33m%s\n\033[0m", NR, $12, $13, $14 }'
		else
			# Check if the root account has no crontab or if authentication failed.
			if [ "$rootSchedules" == "no crontab for root" ]; then
				echo -e "\nNo backup schedules set for root.${RESET}"
			else
				echo -e "\nCould not fetch backups created as root.${RESET}"
			fi
		fi
	fi

	# Display schedules for users
	if [ $(echo -n "$userSchedules" | wc -c) -ne 0 ]; then
		# Get the backup folders 
		backupFolders=$(
			echo "$userSchedules" |
			cut -f13 -d" " |
			sed "s/\"//g"
		)
		# Get the backup filenames
		backupFiles=$(
			echo "$userSchedules" |
			cut -f12 -d" " |
			grep -Po "[^/]+\"$" | 
			sed "s/\"//g"
		)
		# Combine the paths of folder and file
		backupFiles=$(paste <(echo "$backupFolders") <(echo "$backupFiles") -d "")

		# Get the last modification time of the backup files
		backupTimes=""
		for file in $backupFiles
		do
			time=$(stat --format='%y' "$file" 2>&1)
			if [ $? -ne 0 ]; then
				backupTimes+="Never."
			else
				backupTimes+=$(echo "$time" | cut -d" " -f1)
			fi
			backupTimes+=$'\n'
		done

		# Remove the trailing newline
		backupTimes=$(echo -n "$backupTimes")

		# Combine the dates to the user schedule strings so its accessible
		# via awk
		userSchedules=$(paste <(echo "$userSchedules") <(echo "$backupTimes") -d" " 2> /dev/null)

		# Print the user schedules
		echo "$userSchedules" | awk '{ printf "\n\033[36m(\033[32mUser\033[36m) Schedule \033[32m%d\033[36m:\nFile to backup: \033[33m%s\n\033[36mBackup Location: \033[33m%s\n\033[36mLast backup time: \033[33m%s\n\033[0m", NR, $12, $13, $14 }'
	else
		echo -e "\nNo backup schedules set for user.${RESET}"
	fi
	echo ""
}

# Main Loop
# Define the list of available options
options=(
	"$(echo -e "${YELLOW}Create New Backup Schedule${RESET}")"
	"$(echo -e "${YELLOW}Display Current Backup Schedules${RESET}")"
	"$(echo -e "${YELLOW}Go Back to Main Menu${RESET}")"
)

# Customise the input prompt
echo -e "${PURPLE}BACKUP MANAGEMENT${RESET}\n"
PS3=$(echo -e -n "\n${GREEN}Please select an option: ${RESET}")

# Print a menu containing all available options
select option in "${options[@]}"; 
do
	case $option in
		"${options[0]}")
			createNewBackupSchedule
			;;
		"${options[1]}")
			displayCurrentBackupSchedules
			;;
		"${options[2]}")
			exit 0
			;;
		*)
			echo -e "\n${RED}Invalid Option!${RESET}\n"
			;;
	esac
	REPLY=
done
