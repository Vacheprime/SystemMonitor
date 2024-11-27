#!/bin/bash

# System Status Functions
# Display the swap memory usage, the cached memory, the process memory usage,
# and the totalavailable memory
function getMemoryStatus() {
	echo "Current Memory Usage:"
	# The 'free' command is used to display the amount of free and used RAM
	# The -L option prints the results on one line instead of a table
	# The -h option prints the amounts in human readable format
	# The --si option prints the amounts using kilo, mega, giga instead of kibi, mebi, gibi
	# The 'awk' command is used to extract the amounts from the output based on index
	memoryUsage=$(free -h --si)
	echo "$memoryUsage" | awk 'NR==3 {printf "Swap Memory Usage: %s\n", $2}'
	echo "$memoryUsage" | awk 'NR==2 {printf "Cache Memory Usage: %s\nMemory Usage: %s\nAvailableMemory: %s\n", $6, $3, $7}'
}

# Check the CPU Temperature, and sound an alarm if the temperature
# is greater than 70C
checkCPUTemperature () {
	# Finding the CPU temperature requires the 'inxi' command
	# Check if 'inxi' is installed first
	if ! which inxi > /dev/null; then
		echo "Error: The 'inxi' command must be installed to check the CPU temperature!"
		return 1
	fi
	# The 'inxi -s' command is used to display the temperature of the CPU and GPU
	# The 'grep' command is used to search for the CPU temperature using a regex
	# The -P option is used to indicate PERL regex functionalities
	# The -o option is used to print only the matching part of the regex and not the
	# whole line
	temp=$(inxi -s | grep -Po "(?<=cpu:\s)\d+.\d")
	# Define the CPU temperature limit
	limit=70
	# Display the CPU temperature
	echo "The CPU temperature is at $temp°C"
	# Use 'bc' to compare decimal numbers
	if [ $(echo "$temp > $limit" | bc ) -eq 1 ]; then
		echo "[WARNING] The CPU temperature is greater than $limit°C!"
		# Beeping noise code taken from https://unix.stackexchange.com/questions/1974/how-do-i-make-my-pc-speaker-beep
		for i in $(seq 0 3); do
			$( speaker-test -c2 -t sine -f 1000 & pid=$! ; sleep 0.1s ; kill -9 $pid) &> /dev/null
			sleep 0.1s
		done
	fi
}

# List currently active processes
listProcesses() {
	# The 'ps' command is used to display all active processes
	# The 'a' option is used to print processes from all users
	# The 'u' option is used to show the user column
	# The 'x' option is used to print processes that hae not been started from the
	# terminal
	# The 'less' command is used to display the results in an interactive window
	# The -S option is used to disable line wrapping
	ps aux | less -S
}

# List the currently active processes in a minimal fashion for the killProcess function
listProcessesMinimal() {
	# Note: pr command to display as table
	# Note: processes in [] are kernel processes
	fullOutput=$(ps aux)
	pids=$(echo "$fullOutput" | tail -n +2 | awk '{printf "%s\n", $2}')
	processNames=$(echo "$fullOutput" | tail -n +2 | awk '{printf "%s\n", $11}' | sed "s/\/.*\]/\]/" | grep -Po "((?<=/)?[^/]*$)")

}

# Kill a process
killProcess() {
	# Get the current user's ID
	cuid=$(id -u)
	# Read the process ID from the user
	read -p "Enter the ID of the process you would like to stop: " processID
	
	# PID 1 is a process that cannot be killed.
	if [ $processID -eq 1 ]; then
		echo "PID 1 cannot be killed!"
		return 1	
	fi	

	# Check whether the process ID corresponds to an active process
	if ps "$processID" > /dev/null; then
		# Get the User ID of the user that started the process to kill
		# ps -f n lists information about the process ID using numerical values
		# for the UserID
		# --pid selects the process based on process ID
		# The 'awk' command is used to retrieve the UserID
		puid=$(ps -f n --pid "$processID" | awk 'NR==2 {print $1}')
		select signalOpt in "Forceful Kill" "Graceful Kill" "Cancel"
		do
			case $signalOpt in
				"Forceful Kill")
					if [ $cuid -eq $puid ]; then
						# The 'kill' command is used to stop a process
						# The -9 option is used to specify signal 9, SIGKILL, which
						# forcefully kills a process
						kill -9 $processID
						if ! ps "$processID" > /dev/null; then
							echo "The process has been forcefully killed!"
						else
							echo "The process could not be killed!"
						fi
					else
						echo "The current user does not have permission to kill this process."
						read -p "Would you like to try with root permissions? [y/n]: " doTry
						if [ "$doTry" != "y" ]; then
							echo "The operation has been cancelled!"
							break
						fi

						sudo kill -9 $processID
						if ! ps "$processID" > /dev/null; then
							echo "The process has been forcefully killed!"
						else
							echo "The process could not be killed!"
						fi
					fi
					break
					;;
				"Graceful Kill")
					if [ $cuid -eq $puid ]; then
						# The -15 option is used to specify signal 15, SIGTERM which
						# gracefully kills a process
						kill -15 $processID
						if ! ps "$processID" > /dev/null; then
							echo "The process has been gracefully killed!"
						else
							echo "The process could not be killed!"
						fi
					else
						echo "The current user does not have permission to kill this process."
						read -p "Would you like to try with root permissions? [y/n]: " doTry
						if [ "$doTry" != "y" ]; then
							echo "The operation has been cancelled!"
							break
						fi

						sudo kill -15 $processID
						if ! ps "$processID" > /dev/null; then
							echo "The process has been gracefully killed!"
						else
							echo "The process could not be killed!"
						fi
					fi
					break
					;;
				"Cancel")
					# Cancel the operation
					echo "The operation has been cancelled!"
					break
					;;
				*)
					# Notify the user of the invalid option
					echo "Invalid Option!"
					;;
			esac
			# Make the REPLY variable empty to force the select statement to reprint the menu
			REPLY=
		done
	else
		# Notify the user that the processID entered does not 
		# correspond to an active process
		echo "The process with id $processID does not exist!"
	fi	
}

# Main Loop
# Define the list of available options
options=("Memory Status" "CPU Temperature" "List Processes" "Stop Process" "Exit")

# Customise the input prompt
PS3="Please select an option: "

# Print a menu containing all available options and request the user to choose
select option in "${options[@]}"
do
	# Execute the appropriate action according to the user's choice
	case "$option" in
		"Memory Status")
			getMemoryStatus
			;;
		"CPU Temperature")
			checkCPUTemperature 
			;;
		"List Processes")
			listProcesses
			;;
		"Stop Process")
			killProcess
			;;
		"Exit")
			exit 0
			;;
		*)
			echo "Invalid option!"
			;;
	esac
	# Make the REPLY variable empty to force the select statement to reprint the menu
	REPLY=
done
