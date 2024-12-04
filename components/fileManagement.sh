#!/bin/bash

# Colors:
CYAN=$(tput setaf 6)
PURPLE=$(tput setaf 5)
BLUE=$(tput setaf 4)
YELLOW=$(tput setaf 3)
GREEN=$(tput setaf 2)
RED=$(tput setaf 1)
RESET=$(tput sgr0)

# NOTE: Searching a file in the user's home directory will in a function,
# and the unsername validation will be outside  of the function

# Accept the file name as input and search it inside the specified user's home direcory.
# If the file is found, print the full path, if not, then print an error message
findFileInHomeDir(){
# New Steps: use sudo find to recursively search for the given file

# 3. If the home directory is not readable, then use sudo find to search for the file
   read -p "${PURPLE}Enter the name of the file: ${RESET}" filename
	   found_file=$(sudo find "$1" -type f -name "$filename" 2>/dev/null | head -n 1)
	   if [ -n "$found_file" ]; then
		echo "${GREEN}File found: $found_file ${RESET}"
	   else
		echo "${RED}Error: File '$filename' not found in $1 ${RESET}"
	  fi
}

#• Display the 10 largest files in the user's home directory.
# Ignore the .dbus permissions
# -exec stat: exec allows 'find' to use 'stat' on each file that is found
# 'stat' displays the information on each file found:
        # %s: size in bytes
        # %n: name of the full path
# {}: ensures that '-exec' knows where to insert the path of the file. 'stat' would not know which file to act upon without it.
displayTenLargestFiles(){
   echo "${CYAN}10 Largest Files ${RESET}"
   echo "${PURPLE}SIZE (MB) | FULL PATH OF THE FILE ${RESET}"
	find "$1" -type f ! -path "$1/$username/.dbus" -exec stat --format="%s %n" {} + 2>/dev/null | sort -rh | head
}

#• Display the 10 oldest files in the user's home directory.
displayTenOldestFiles(){
   echo "${CYAN}10 Oldest Files ${RESET}"
   echo "${PURPLE}LAST DATE OF MODIFICATION | FULL PATH OF THE FILE ${RESET}"
	# %T+: Prints the last modification time of the file (format: year-month-day+hours:minutes:seconds)
	# %p: Prints the full path of the file
	# 2>dev/null: Suppress the permission denied message, even when the command prints the expected results
	find "$1" -type f -printf '%T+ %p\n' 2>/dev/null | sort | head
}

#• Accept an email address and a file name from the user, and send the file as an email attachment
sendFileAsEmailAttachment(){

	# This will be used in case the user does not have the mutt command installed
	command_installer=$"./installCommand.sh"

	read -p "${CYAN}Enter the email address: ${RESET}" email
	read -p "${PURPLE}Enter the file name to send as an email attachment: ${RESET}" filename

	#Validate the email format using regex
	if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
		# Check if the mutt command is installed
                if ! which mutt > /dev/null; then
                	if [ ! -f "$command_installer" ]; then
        	                echo "${RED}Error: Command installer script '$command_installer' does not exists${RESET}"
                                return 1
                        fi

                        # Install the mutt command using the installer script
                        $command_installer mutt &> /dev/null
                        if [ $? -ne 0 ]; then
 	                       echo "${RED}Failed to install 'mutt' command. Exiting...${RESET}"
                               return 1
                        fi
                fi

		#Check if the file exists
		if [ -f "$1/$filename" ]; then
			echo "${GREEN}Sending the file as an email attachment...${RESET}"
			# echo before the pipe: will be written inside the body of the email
			# mutt command (mail command did not work): tool to read and send emails
			# -s option: specifies the subject of the email (Sending File filename)
			# -a option: attach a file to the email(full path of the file to the email address inputed by the user)
			# (changes: check if the mutt command is installed)

			echo "Please find the file attached." | mutt -s "Sending File: $filename" -a "$1/$filename" -- "$email"

			# Error Handling: Check the exit status to see if program ran successfully
			if [ $? -eq 0 ]; then
				echo "${GREEN}File sent successfully.${RESET}"
			else
				echo "${RED}File not found in the directory.${RESET}"
			fi
		fi
	else
		echo "${RED}Invalid email address. Please enter an email with a valid format.${RESET}"
	fi
}

# Main

# Accept the username as input
while true; do
read -p "${CYAN}Enter the username (or enter 'Exit' to leave the program): ${RESET}" username

if [[ "$username" == "Exit" ]]; then
   echo "${YELLOW}Exiting the Program...${RESET}"
   exit 0
fi
# Check if the user exists
if id "$username" &>/dev/null; then
   # If the username exists, get the home directory by extracting it from /etc/passwd
   # -d option with cut command: Seperate the fields of the etc/passwd with the colon delimeter
   # f6: extract the home directory ( which is the 6th field inside etc/passwd)
   home_dir=$(grep "^$username:" /etc/passwd | cut -d: -f6
   # Check if the home directory exists
   if  [ -d "$home_dir" ]; then
	# Run this menu until the use chooses to exit
	while true; do
	# Prompt the user with message asking to choose an option in the file management program
	PS3="${BLUE}Please select an option: ${RESET}"
	select option in "Go Back to Menu" "Search For a File" "Find the 10 Largest Files" "Find the 10 Oldest Files" "Send File as An Email Attachment" "Exit";

	    do
	    	 case $option in
			"Go Back to Menu")
				exit 0
				;;
			"Search For a File")
				findFileInHomeDir "$home_dir"
				break
				;;
			"Find the 10 Largest Files")
				displayTenLargestFiles "$home_dir"
				break
				;;
			"Find the 10 Oldest Files")
				displayTenOldestFiles "$home_dir"
				break
				;;
			"Send File as An Email Attachment")
				sendFileAsEmailAttachment "$home_dir"
				break
				;;
			"Exit")
				echo "${YELLOW}Exiting file management program...${RESET}"
				exit 0
				;;
			*)
				echo "${RED}Invalid Option. Please try again.${RESET}"
				;;
	   	 esac
	    done
	done
   else
	echo "${RED}Home directory does not exists${RESET}"
   fi

else

   echo "${RED}User does not exists${RESET}"

fi
done
#End of the Program
