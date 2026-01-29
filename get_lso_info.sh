#!/bin/bash
# Script to collect data generating a output file with the hostname + date and extension .out
# You can debug executing 'bash -x scriptname.sh' with root privileges
# You need to check if devices are sdX or vdX and change as required head command from below

# Variables
FILENAME=$(hostname)_$(date -I).out 
ITEMS=(
"hostname"
"lsblk"
"ls -lR /dev/disk/by-*"
"ls -lR /mnt/local-storage/"
"head --bytes=60 /dev/sd[a-z]"
"head --bytes=60 /dev/vd[a-z]"
"head --bytes=60 /dev/nvme[0-9]n[0-1]"
"head --bytes=60 /dev/nvme[0-9]n[0-1]p[0-1]"
) 

# Control the field separator for array spaces
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
 
# Function
collect_data () {
for i in ${ITEMS[@]}
do echo '' >> $FILENAME
        echo "#> $i" >> $FILENAME
        eval "$i" >> $FILENAME 2>&1
done
}
 
# Main
collect_data
