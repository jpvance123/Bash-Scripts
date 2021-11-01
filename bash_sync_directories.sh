#!/usr/bin/bash
#
#	John Vance
#	CS-406 Basic Linux Systems Admin
# 	Lab#2 Shell Scripting syncdirs
# 	Usage: syncdirs DIRECTORY1 DIRECTORY2
#
#	Script synchronizes two given directories so that all regular files are the  
#	same in both directories.


function print_usage()
{
	echo "Usage: syncdirs DIRECTORY1 DIRECTORY2" >&2
}

# Check that correct number of args were given:
if [[ $# != 2 ]]; then
    print_usage
    exit 1
fi

# Save args into relative(user inputted so it could be relative) path variable to be referenced
# Save args into full paths to be used with commands to ensure correct execution
rel_dir_one="$1"
rel_dir_two="$2"
DIRECTORY_ONE=$(realpath "$rel_dir_one")
DIRECTORY_TWO=$(realpath "$rel_dir_two")

# Check that specified root directory in indeed a directroy,
# otherwise print an eroor message and exit as failure:
if [[ ! -d "$DIRECTORY_ONE" ]] ; then
	echo "DIRECTORY_ONE argument is not a valid directory: $DIRECTORY_ONE"
    	exit 1
fi

if [[ ! -d "$DIRECTORY_TWO" ]] ; then
	echo "DIRECTORY_TWO argument is not a valid directory: $DIRECTORY_TWO"
    	exit 1
fi


#####################################################################################
# Two functions, process_dir_one() and process_dir_two()
#####################################################################################

# process_dir_one
# function loops through source directory which is the first directory given by user
# for all files in DIRECTORY_ONE do
# For each file in DIRECTORY_ONE we create an expected file name for directory two
# If not found in directory two we copy the file from directory one
# If file is in both we check if they have the same contents ( If they do continue)
# If not we check which was last updated and copy accordingly


function process_dir_one()
{
	for file_source in "$DIRECTORY_ONE"/*;
	do
		file_dest="$DIRECTORY_TWO/$( basename "$file_source")"
		if [ -f "$file_source" ]; then 
			if [ ! -e "$file_dest" ]; then
				printf 'copying %s, ' "$( basename "$file_source")"
				printf 'from %s ' "$file_source"
				printf 'to %s\n' "$file_dest"
				cp -f "$file_source" "$file_dest"
			elif cmp -s -- "${file_source}" "${file_dest}" 
			then
				continue
			else	
				if [ "$file_source" -nt "$file_dest" ]; then
					echo "copying $( basename "$file_source") from $file_source OVER $( basename "$file_dest") in $file_dest"
					cp -f "$file_source" "$file_dest" 
				else
					echo "copying $( basename "$file_dest") from $file_dest OVER $( basename "$file_source") in $file_source"
					cp -f "$file_dest" "$file_source"
				fi
			fi
		else
			echo "$( basename "$file_source") in $file_source is a directory and not a file" 
		fi
	done
}

# process_dir_two()
# Uses identical logic like process_dir_one but stops after checking if files aren't present because
# if they're the same they're already fine or have been copied to the newest version by our first function

function process_dir_two()
{
	for file_source in "$DIRECTORY_TWO"/*;
	do
		file_dest="$DIRECTORY_ONE/$( basename "$file_source")"
		if [ -f "$file_source" ]; then
			if [ ! -e "$file_dest" ]; then
				printf 'copying %s, ' "$( basename "$file_source")"
				printf 'from %s ' "$file_source"
				printf 'to %s\n' "$file_dest"
				cp -f "$file_source" "$file_dest"
			else
				continue
			fi
		else
			echo "$( basename "$file_source") in "$file_source" is a directory and not a file"
		fi 
	done
}

#####################################################################################


# Start the sychronization of directories
printf '\nSynchronizaiton of %s is under way!\n' "$rel_dir_one"
printf '#########################################################################################\n'
process_dir_one "$DIRECTORY_ONE"
printf "\nSynchronization from $rel_dir_one complete. Stand by for synchrinization of $rel_dir_two"
printf '\n#########################################################################################\n'
process_dir_two "$DIRECTORY_TWO"
printf '\nSynchronization complete!\n'


#Successful completion:
exit 0

#EOF



