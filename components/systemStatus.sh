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
	# Use 'bc' to compare decimal numbers
	if [ $(echo "$temp > $limit" | bc ) -eq 1 ]; then
		echo "[WARNING] The CPU temperature is greater than $limit°C!"
		# TODO: Produce a beeping noise
	else
		# Display the CPU temperature
		echo "The CPU temperature is at $temp°C"
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

# TODO Check if 'kill' command completes successfully
# Kill a process
killProcess() {
	# Read the process ID from the user
	read -p "Enter the ID of the process you would like to stop: " processID
	# Check whether the process ID corresponds to an active process
	ps $processID > /dev/null
	if [ $? -eq 0 ]; then
		select signalOpt in "Forceful Kill" "Graceful Kill" "Cancel"
		do
			case $signalOpt in
				"Forceful Kill")
					# The 'kill' command is used to stop a process
					# The -9 option is used to specify signal 9, SIGKILL which
					# forcefully kills a process
					kill -9 $processID
					echo "The process has been forcefully killed!"
					break
					;;
				"Graceful Kill")
					# The -15 option is used to specify signal 15, SIGTERM which
					# gracefully kills a process
					kill -15 $processID
					echo "The process has been gracefully killed!"
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
