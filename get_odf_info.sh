#!/bin/bash
# Script to manual collect ceph info by RafRojas RedHat Support
# This script will set some variables to use on a loop of commands and collect
# the output on a new file with hostname and date.out

#-- Variables --
FILENAME=odf_$(hostname)_$(date -I).out
TOOLPOD=$(oc get pods -n openshift-storage -l app=rook-ceph-tools -o name)
#CEPHCMD_ERR="timeout 10s oc exec $TOOLPOD -n openshift-storage --"
ODFCMD="oc get -n openshift-storage "

#-- List of commands --
ITEMS=(
"$ODFCMD  clusterversion"
"$ODFCMD  csv"
"$ODFCMD  pods -owide"
"$ODFCMD  all"
"$ODFCMD  pv"
"$ODFCMD  sc"
"$ODFCMD  storagecluster -o yaml"
"$ODFCMD  events --sort-by='.lastTimestamp' -n openshift-storage"
"oc -n openshift-local-storage describe localvolumeset localblock"
"$ODFCMD  pvc -n opensift-storage"
"oc describe pvc-73749495-3ca3-41b9-95ef-47c35a3f751b"
"$ODFCMD  deployments"
)

#-- Control the field separator for array spaces --
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

#-- Function --
collect_data () {
echo "=====-----_____ ODF REPORT _____-----======" > $FILENAME
for i in ${ITEMS[@]}
do echo '' >> $FILENAME
        echo "#> $i" >> $FILENAME
        eval "$i" >> $FILENAME
done
}

#Main
collect_data
