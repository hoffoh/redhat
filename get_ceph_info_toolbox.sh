#!/bin/bash
# Collects ceph data using toolbox pod (REQUIRED TOOLBOX POD)
# Script to manual collect ceph info by RafRojas RedHat Support
# This script will set some variables to use on a loop of commands and collect
# the output on a new file with hostname and date.out

#--  Variables --
FILENAME=ceph_$(hostname)_$(date -I).out
TOOLPOD=$(oc get pods -n openshift-storage -l app=rook-ceph-tools -o name)
#CEPHCMD_ERR="timeout 10s oc exec $TOOLPOD -n openshift-storage --"
CEPHCMD="oc exec $TOOLPOD -n openshift-storage --"

# List of commands
ITEMS=(
"$CEPHCMD ceph status"
"$CEPHCMD ceph df detail"
"$CEPHCMD ceph health detail"
"$CEPHCMD ceph crash ls"
"$CEPHCMD ceph fs status"
"$CEPHCMD ceph device ls"
"$CEPHCMD ceph config dump"
"$CEPHCMD ceph osd dump"
)

#-- Control the field separator for array spaces --
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

#-- Function --
collect_data () {
echo "=====-----_____ CEPH REPORT _____-----======" > $FILENAME
for i in ${ITEMS[@]}
do echo '' >> $FILENAME
        echo "#> $i" >> $FILENAME
        eval "$i" >> $FILENAME
done
}

#Main
collect_data
