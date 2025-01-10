#!/bin/sh

# Write a shell script finder-app/writer.sh as described below
# * Accepts the following arguments:
#	the first argument is a full path to a file (including
# 	filename) on the filesystem, referred to below as 'writefile';
#	the second argument is a text string which will be written
#	within this file, referred to below as 'writestr'
#
# * Exits with value 1 error and print statements if any of the
#   arguments above were not specified
#
# * Creates a new file with name and path writefile with content
#   'writestr', overwriting any existing file and creating the path
#   if it doesn’t exist. Exits with value 1 and error print statement
#   if the file could not be created.
#
# Example:
#       writer.sh /tmp/aesd/assignment1/sample.txt ios
#
# Creates file:
#    /tmp/aesd/assignment1/sample.txt
#            With content:
#            ios

if [ $# -ne 2 ]
        then
                echo "Error: The script needs 2 parameters!"
                echo "Script usage: $0 <writefile> <writestring>"
                exit 1
        else
                writefile=$1
                writestr=$2
		path=$(dirname $1)
		if [ -d $path ] # check if directory  exists
			then
		        	if [ -f $writefile ]    # check if file exists
						then
                               			 	if [ -w $writefile ]    #chek if we can overwrite the file
                                        			then
		                                                	echo $writestr > $writefile
                		                        	else
                                		                	echo "Error: We cannot write to file."
                                               			 	exit 1
                                			fi
	                        		else    # we do not have a file, we write one
        	                        		echo $writestr > $writefile
              			fi
        		else    # we create the directory and we write the file
		                mkdir -p $path
                		echo $writestr > $writefile
		fi

fi
