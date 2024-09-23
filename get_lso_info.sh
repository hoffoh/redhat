#!/bin/bash
# Script to collect data generating a output file with the hostname + date and extension .out
# You can debug executing 'bash -x scriptname.sh' with root privileges
# Variables
FILENAME=$(hostname)_$(date -I).out 
ITEMS=(
"hostname"
"lsblk"
"ls -lR /dev/disk/by-*"
"ls -lR /mnt/local-storage/"
"head --bytes=60 /dev/sda"
"head --bytes=60 /dev/sdb"
"head --bytes=60 /dev/sdc"
"head --bytes=60 /dev/sdd"
"head --bytes=60 /dev/sde"
"head --bytes=60 /dev/sdf"
"head --bytes=60 /dev/sdg"
"head --bytes=60 /dev/sdh"
"head --bytes=60 /dev/sdi"
"head --bytes=60 /dev/sdj"
) 
# Control the field separator for array spaces
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")
 
# Function
collect_data () {
for i in ${ITEMS[@]}
do echo '' >> $FILENAME
        echo "#> $i" >> $FILENAME
        eval "$i" >> $FILENAME
done
}
 
# Main
collect_data
