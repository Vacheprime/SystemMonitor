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

# System Status Functions
# Display the swap memory usage, the cached memory, the process memory usage,
# and the totalavailable memory
function getMemoryStatus() {
	echo -e "\n${PURPLE}Current Memory Usage${RESET}\n"
	# The 'free' command is used to display the amount of free and used RAM
	# The -L option prints the results on one line instead of a table
	# The -h option prints the amounts in human readable format
	# The --si option prints the amounts using kilo, mega, giga instead of kibi, mebi, gibi
	# The 'awk' command is used to extract the amounts from the output based on index
	memoryUsage=$(free -h --si)
	echo "$memoryUsage" | awk 'NR==3 {printf "\033[36mSwap Memory Usage: \033[32m%s\033[0m\n", $2}'
	echo "$memoryUsage" | awk 'NR==2 {printf "\033[36mCache Memory Usage: \033[32m%s\033[36m\nMemory Usage: \033[32m%s\033[36m\nAvailableMemory: \033[32m%s\033[0m\n", $6, $3, $7}'
	echo ""
}

# Check the CPU Temperature, and sound an alarm if the temperature
# is greater than 70C
checkCPUTemperature () {
	# Finding the CPU temperature requires the 'inxi' command
	# Check if 'inxi' is installed first
	if ! bash components/installCommand.sh "inxi"; then
		echo -e "${RED}\nCould not install the 'inxi' command used to check CPU temperature!${RESET}"
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
	echo -e "\n${CYAN}The CPU temperature is at ${YELLOW}$temp°C${RESET}"
	# Use 'bc' to compare decimal numbers
	if [ $(echo "$temp > $limit" | bc ) -eq 1 ]; then
		echo -e "\n${RED}[WARNING] The CPU temperature is greater than $limit°C!${RESET}"
		# Beeping noise code taken from https://unix.stackexchange.com/questions/1974/how-do-i-make-my-pc-speaker-beep
		for i in $(seq 0 3); do
			$( speaker-test -c2 -t sine -f 1000 && pid=$! && sleep 0.1s && kill -9 $pid ) &> /dev/null
			sleep 0.1s
		done
	fi
	echo ""
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

# Get the list the of all killable processes
getAllKillableProcesses() {
	ps aux |
	grep -Pv '\[.*\]' |
	tail -n +3 | # Skip the header table row and PID 1
	grep -Pv '\[.*\]' # Exclude kernel processes as those cannot be killed
}


# Extract the list of all killable process Ids
getKillableProcessIds() {
	# $1 corresponds to the list of processes	
	echo "$1" | awk '{printf "%s|%s\n", $2, $1}'
}

# List the currently active processes in a minimal fashion for the killProcess function
listProcessesMinimal() {
	# $0 corresponds to the list of killable processes
	userPids=($(getKillableProcessIds "$1"))
	currentUser=$(whoami)

	# Color the pids
	coloredPids=""
	for userPid in "${userPids[@]}"
	do
		user=$(echo "$userPid" | cut -d "|" -f 2)
		pid=$(echo "$userPid" | cut -d "|" -f 1)
		if [[ "$user" == "$currentUser" ]]; then
			coloredPids+="${GREEN}*$pid${RESET}\n"
		elif [[ "$user" == "root" ]]; then
			coloredPids+="${RED}*$pid${RESET}\n"
		else
			coloredPids+="${YELLOW}*$pid${RESET}\n"
		fi
	done
	coloredPids=$(echo -n "$coloredPids")
	# Color the pids
	# Extract the list of all command names without the full path
	# and without any arguments to keep the interface clean
	commandNames=$(
		echo "$1" |
		awk '{printf "%s\n", $11}' | # Extract column 11, command names
		grep -Po '(?<=/)[^/]+?$|^[^/]+?$'  # Extract the command names without full path
	)
	# Combine the pids and command name and display as columns
	echo ""
	paste -d' ' <(echo -e -n "$coloredPids") <(echo -e "$commandNames")  | column -c 80 | sed 's/\*//g' | column
	echo -e "\n${RED}RED = ROOT ${YELLOW}YELLOW = OTHER USER ${GREEN}GREEN = CURRENT USER${RESET}"
	echo -e "${RESET}"
}

# Kill a process
killProcess() {
	# Get killable processes as string
	killableProcesses=$(getAllKillableProcesses)

	# Get killable process Ids as array
	killablePids=($(getKillableProcessIds "$killableProcesses"))

	# List the killable processes
	listProcessesMinimal "$killableProcesses"

	# Get the current user's ID
	cuid=$(id -u)

	# Read the process ID from the user
	echo -e -n "${CYAN}Enter the ID of the process you would like to stop: ${RESET}"
	read processID

	# Check if user input is valid
	if ! [[ "$processID" =~ ^[0-9]+$ ]]; then
		echo -e "\n${RED}You must enter a valid PID!${RESET}\n"
		return 1
	fi

	# Check if the process ID is in the list of killable processes
	isPresent=0
	for pid in "${killablePids[@]}"; do
		if [[ "$pid" -eq "$processID" ]]; then
			isPresent=1
		fi
	done

	if [[ "$isPresent" -eq 0 ]]; then
		echo -e "\n${RED}You must enter a PID from the list of killable processes!${RESET}\n"
		return 1
	fi

	# Check whether the process ID corresponds to an active process
	if ! ps --pid "$processID" &> /dev/null; then
		# Notify the user that the processID entered does not 
		# correspond to an active process
		echo -e "\n${GREEN}The process with id $processID has already terminated!${RESET}\n"
		return 1
	fi

	# Get the User ID of the user that started the process to kill
	# ps -f n lists information about the process ID using numerical values
	# for the UserID
	# --pid selects the process based on process ID
	# The 'awk' command is used to retrieve the UserID
	echo ""
	signalOptions=(
		"$(echo -e "${YELLOW}Forceful Kill${RESET}")"
		"$(echo -e "${YELLOW}Graceful Kill${RESET}")"
		"$(echo -e "${YELLOW}Cancel${RESET}")"
	)
	puid=$(ps -f n --pid "$processID" | awk 'NR==2 {print $1}')
	select signalOpt in "${signalOptions[@]}"
	do
		case "$signalOpt" in
			"${signalOptions[0]}")
				if [ $cuid -eq $puid ]; then
					# The 'kill' command is used to stop a process
					# The -9 option is used to specify signal 9, SIGKILL, which
					# forcefully kills a process
					kill -9 $processID
					if ! ps "$processID" > /dev/null; then
						echo -e "${GREEN}\nThe process has been forcefully killed!${RESET}\n"
					else
						echo -e "${RED}The process could not be killed!${RESET}\n"
					fi
				else
					echo -e "\n${YELLOW}The current user does not have permission to kill this process."
					echo -e -n "Would you like to try with root permissions?${RESET} [${GREEN}y${RESET}/${RED}n${RESET}]: "
					read doTry
					if [ "$doTry" != "y" ]; then
						echo -e "\n${YELLOW}The operation has been cancelled!${RESET}\n"
						break
					fi

					sudo kill -9 $processID
					if ! ps "$processID" > /dev/null; then
						echo -e "\n${GREEN}The process has been forcefully killed!${RESET}\n"
					else
						echo -e "\n${RED}The process could not be killed!${RESET}\n"
					fi
				fi
				break
				;;
			"${signalOptions[1]}")
				if [ $cuid -eq $puid ]; then
					# The -15 option is used to specify signal 15, SIGTERM which
					# gracefully kills a process
					kill -15 $processID
					if ! ps "$processID" > /dev/null; then
						echo -e "\n${GREEN}The process has been gracefully killed!${RESET}\n"
					else
						echo -e "\n${RED}The process could not be killed!${RESET}\n"
					fi
				else
					echo -e "\n${YELLOW}The current user does not have permission to kill this process."
					echo -e -n "Would you like to try with root permissions?${RESET} [${GREEN}y${RESET}/${RED}n${RESET}]: "
					read doTry
					if [ "$doTry" != "y" ]; then
						echo -e "\n${YELLOW}The operation has been cancelled!${RESET}\n"
						break
					fi

					sudo kill -15 $processID
					if ! ps "$processID" > /dev/null; then
						echo -e "\n${GREEN}The process has been gracefully killed!${RESET}\n"
					else
						echo -e "\n${RED}The process could not be killed!${RESET}\n"
					fi
				fi
				break
				;;
			"${signalOptions[2]}")
				# Cancel the operation
				echo -e "\n${YELLOW}The operation has been cancelled!${RESET}\n"
				break
				;;
			*)
				# Notify the user of the invalid option
				echo -e "\n${RED}Invalid Option!${RESET}\n"
				;;
		esac
		# Make the REPLY variable empty to force the select statement to reprint the menu
		REPLY=
	done
}

# Main Loop
# Define the list of available options
options=(
	"$(echo -e "${YELLOW}Memory Status${RESET}")"
	"$(echo -e "${YELLOW}CPU Temperature${RESET}")"
	"$(echo -e "${YELLOW}List Processes${RESET}")"
	"$(echo -e "${YELLOW}Stop Process${RESET}")"
	"$(echo -e "${YELLOW}Go Back to Main Menu${RESET}")"
)
# Print the main menu
echo -e "${PURPLE}SYSTEM STATUS${RESET}\n"

# Customise the input prompt
PS3=$(echo -e -n "${GREEN}\nPlease select an option: ${RESET}")

# Print a menu containing all available options and request the user to choose
select option in "${options[@]}"
do
	# Execute the appropriate action according to the user's choice
	case "$option" in
		"${options[0]}")
			getMemoryStatus
			;;
		"${options[1]}")
			checkCPUTemperature 
			;;
		"${options[2]}")
			listProcesses
			;;
		"${options[3]}")
			killProcess
			;;
		"${options[4]}")
			exit 0
			;;
		*)
			echo -e "\n${RED}Please enter a valid option!${RESET}\n"
			;;
	esac
	# Make the REPLY variable empty to force the select statement to reprint the menu
	REPLY=
done
