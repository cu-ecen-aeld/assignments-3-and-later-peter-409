#!/bin/sh

# * Accepts the following runtime arguments:
#	the first argument is a path to a directory on the filesystem, referred to below as 'filesdir';
#	the second argument is a text string which will be searched within these files, referred to below as 'searchstr'
#
# * Exits with return value 1 error and print statements if any of the parameters above were not specified
# * Exits with return value 1 error and print statements if filesdir does not represent a directory on the filesystem
# * Prints a message "The number of files are X and the number of matching lines are Y" where X is the number of files
#   in the directory and all subdirectories and Y is the number of matching lines found in respective files, where a
#   matching line refers to a line which contains searchstr (and may also contain additional content).
#
# Example invocation:
#       finder.sh /tmp/aesd/assignment1 linux

# Check parameters, return error if conditions aren't met.
# Assign filesdir and searchstr
if [ $# -ne 2 ]	# More info at: https://linuxhandbook.com/bash-test-operators/
	then
		echo "Error: The script needs 2 parameters!"
		echo "Script usage: $0 <filesdirectory> <searchstring>"
		exit 1
	else
		# Check if filesdir is a valid directory path
		if [ -d "$1" ]	# More info at: https://www.w3schools.io/terminal/bash-check-directory/
			then
			filesdir=$1
		else
			echo "Error: Provided parameter does not represent a directory on the filesystem!"
			echo "Script usage: $0 <filesdirectory> <searchstring>"
			exit 1
		fi
		searchstr=$2
fi

# Search within filesdir for searchstr and count X (the number of files with the string searchstr) and Y (the number of lines with searchstr)
# Using the grep command for searching text in conjunction with wc command
# More info at:
#    * https://www.linuxjournal.com/content/how-search-and-find-files-text-strings-linux
#    * https://linux.die.net/man/1/grep
X=$(grep -rl "$searchstr" "$filesdir" | wc -l)
Y=$(grep -sr "$searchstr" "$filesdir" | wc -l)
# Printing the result
echo "The number of files are $X and the number of matching lines are $Y"
exit 0
