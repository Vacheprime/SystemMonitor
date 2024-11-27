#!/bin/bash

# NOTE: Searching a file in the user's home directory will in a function,
# and the unsername validation will be outside  of the function

# Accept the file name as input and search it inside the specified user's home direcory.
# If the file is found, print the full path, if not, then print an error message
findFileInHomeDir(){
# New Steps: use sudo find to recursively search for the given file

# 3. If the home directory is not readable, then use sudo find to search for the file
   read -p "Enter the name of the file: " filename
	   found_file=$(sudo find "$1" -type f -name "$filename" 2>/dev/null | head -n 1)
	   if [ -n "$found_file" ]; then
		echo "File found: $found_file"
	   else
		echo "Error: File '$filename' not found in $1"
	  fi
}


#• Display the 10 largest files in the user's home directory.
displayTenLargestFiles(){
   echo "10 Largest Files: "
	find "$1" -type f ! -path "$1/$username/.dbus" -exec stat --format="%s %n" {} + 2>/dev/null | sort -rh | head -n 10
}

#• Display the 10 oldest files in the user's home directory.
displayTenOldestFiles(){
   echo "10 Oldest Files: "
	# %T+: Prints the last modification time of the file (format: year-month-day+hours:minutes:seconds)
	# %p: Prints the full path of the file
	# 2>dev/null: Suppress the permission denied message, even when the command prints the expected results
	find "$1" -type f -printf '%T+ %p\n' 2>/dev/null | sort | head -10
}

#• Accept an email address and a file name from the user, and send the file as an email attachment
sendFileAsEmailAttachment(){

	# This will be used in case the user does not have the mutt command installed
	command_installer=$"./installCommand.sh"

	read -p "Enter the email address: " email
	read -p "Enter the file name to send as an email attachment: " filename

	#Validate the email format using regex
	if [[ "$email" =~ ^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
		# Check if the mutt command is installed
                if ! which mutt > /dev/null; then
                	if [ ! -f "$command_installer" ]; then
        	                echo "Error: Command installer script '$command_installer' does not exists"
                                return 1
                        fi

                        # Install the mutt command using the installer script
                        $command_installer mutt &> /dev/null
                        if [ $? -ne 0 ]; then
 	                       echo "Failed to install 'mutt' command. Exiting..."
                               return 1
                        fi
                fi

		#Check if the file exists
		if [ -f "$1/$filename" ]; then
			echo "Sending the file as an email attachment..."
			# echo before the pipe: will be written inside the body of the email
			# mutt command (mail command did not work): tool to read and send emails
			# -s option: specifies the subject of the email (Sending File filename)
			# -a option: attach a file to the email(full path of the file to the email address inputed by the user)
			# (changes: check if the mutt command is installed)

			echo "Please find the file attached." | mutt -s "Sending File: $filename" -a "$1/$filename" -- "$email"

			# Error Handling: Check the exit status to see if program ran successfully
			if [ $? -eq 0 ]; then
				echo "File sent successfully."
			else
				echo "File not found in the directory."
			fi
		fi
	else
		echo "Invalid email address. Please enter an email with a valid format."
	fi
}

# Main

# Accept the username as input
while true; do
read -p "Enter the username (or enter 'Exit' to leave the program): " username

if [[ "$username" == "Exit" ]]; then
   echo "Exiting Program."
   exit 0
fi
# Check if the user exists
if id "$username" &>/dev/null; then
   # If the username exists, get the home directory by extracting it from /etc/passwd
   # -d option with cut command: Seperate the fields of the etc/passwd with the colon delimeter
   # f6: extract the home directory ( which is the 6th field inside etc/passwd)
   home_dir=$(grep "^$username:" /etc/passwd | cut -d: -f6)
	echo "Testing home directory: $home_dir"
   # Check if the home directory exists
   if  [ -d "$home_dir" ]; then
	# Run this menu until the use chooses to exit
	while true; do
	# Prompt the user with message asking to choose an option in the file management program
	PS3="Please select an option: "
	select option in "Search For a File" "Find the 10 Largest Files" "Find the 10 Oldest Files" "Send File as An Email Attachment" "Exit";

	    do
	    	 case $option in
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
				echo "Exiting file management program..."
				exit 0
				;;
			*)
				echo "Invalid Option"
				;;
	   	 esac
	    done
	done
   else
	echo "Home directory does not exists"
   fi

else

   echo "User does not exists"

fi
done
#End of the Program
