#!/usr/bin/env bash

# Ask for locations of from and to directories

# Get locations of from and to directories from script arguments ($1 and $2, $ not needed in substitution below)
# Then substitute tilde in directory path with absolute home path
FromDirectory=${1/\~/$HOME}
ToDirectory=${2/\~/$HOME}

# Ensure that from directory is valid
if [ ! -d "$FromDirectory" ]
then
    echo "Error: $FromDirectory is not a valid directory"
else
    # Ensure that to directory is valid
    if [ ! -d "$ToDirectory" ]
    then
        echo "Error: $ToDirectory is not a valid directory"
    else
        # Get size of from and to directories
        FromDirectorySize=`ls -1q "$FromDirectory" | wc -l`
        ToDirectorySize=`ls -1q "$ToDirectory" | wc -l`

        # Define copied files counter
        CopiedFilesCounter=0

        # Ignore patterns that match "nothing" (such as empty directories)
        shopt -s nullglob

        # If size of from directory is 0, echo error message
        if [ "$FromDirectorySize" -eq "0" ];
        then
            echo "Error: $FromDirectory is empty!"
        else
            # Otherwise, loop through each file in the from directory
            for fromFile in "$FromDirectory"/*; do
                # Store sha512sum of current file in local variable
                fromFileSha=`sha512sum "$fromFile" | awk '{ print $1 }'`

                # Define the should copy flag to true
                shouldCopy=true

                # Loop through each file in to directory if its size is greater than 0
                for toFile in "$ToDirectory"/*; do
                    toFileSha=`sha512sum "$toFile" | awk '{ print $1 }'`

                    # If the sums are the same, then set should copy flag to false
                    if [ "$fromFileSha" == "$toFileSha" ]
                    then
                        shouldCopy=false
                        break
                    fi
                done

                # If should copy flag is true, then copy to the to directory
                if [ "$shouldCopy" = true ]
                then
                    cp "$fromFile" "$ToDirectory"
                    echo "Copied $fromFile"
                    CopiedFilesCounter=$((CopiedFilesCounter+1))
                fi
            done

            echo "Finished copying $CopiedFilesCounter file(s)"
        fi
    fi
fi