#!/bin/bash
# Script to manual collect ceph info by RafRojas RedHat Support
# This script will set some variables to use on a loop of commands and collect
# the output on a new file with hostname and date.out

#-- Variables --
FILENAME=odf_$(hostname)_$(date -I).out
LOGSFILE=odf_$(hostname)_$(date -I)_logs.out
TOOLPOD=$(oc get pods -n openshift-storage -l app=rook-ceph-tools -o name)
#CEPHCMD_ERR="timeout 10s oc exec $TOOLPOD -n openshift-storage --"
ODFCMD="oc get -n openshift-storage "

#-- List of commands --
ITEMS=(
"$ODFCMD  clusterversion"
"$ODFCMD  csv"
"$ODFCMD  subscriptions"
"$ODFCMD  installplan"
"$ODFCMD  pods -owide"
"$ODFCMD  all"
"$ODFCMD  pv"
"$ODFCMD  pvc"
"$ODFCMD  sc"
"$ODFCMD  storagecluster -o yaml"
"$ODFCMD  events --sort-by='.lastTimestamp'"
"$ODFCMD  deployments"
"$ODFCMD  obc"
"$ODFCMD  ob"
"$ODFCMD  backingstore"
"oc describe noobaa" 
)

#-- Control the field separator for array spaces --
SAVEIFS=$IFS
IFS=$(echo -en "\n\b")

#-- Function --
collect_podlogs () {
for MYPOD in $(oc get pods -n openshift-storage --no-headers|grep -v NAME|awk '{ print $1 }')
do echo 'Collecting logs from '$MYPOD >> $MYPOD.log 
   oc logs -n openshift-storage $MYPOD >> $MYPOD.log
done
}

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
collect_podlogs
