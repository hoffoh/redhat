#!/bin/bash
# Script to get report from pre-checks after upgrade, manual intervention is required this only summarizes some info not checking all the data
#Version 1
######################Vars###################################
clear
SPACE="echo " 
LINE="echo -------------------------------------------------------------------------------------------------------"
RED="\0033[1;31m""-------------------------------------------------------------------------------------------------------"
CASENUM=$1

##################Functions##################################

function main_menu (){
FILENAME="$CASENUM"_Pre.out && get_data
echo $FILENAME
}

function get_data (){
$LINE && $SPACE && echo "Looking for ODF must-gathers on case: $CASENUM" && $SPACE && $LINE
MGSUBPATH=$(find  ~/$CASENUM/ -maxdepth 3 -type d | grep registry)
 
if [[ -z $MGSUBPATH ]]
  then
    echo "Cannot find any ODF Must gather on:  ~/$CASENUM"
    $LINE && $SPACE && exit 66
  else
    echo "#    Select the ODF must-gather from list above   #"
    $LINE 
    SEQ=0
    for i in $MGSUBPATH
    do  
      SEQ=$((SEQ+1))
      $SPACE
      echo "  $SEQ: $i"
      $SPACE 
    done 
    $SPACE && $LINE
    read -p "  Insert absolute path from above for the report :> " FINAL_PATH
    $LINE && $LINE
fi
$LINE && $SPACE && echo "$FINAL_PATH" && $SPACE && $LINE
get_ceph
}

function get_ceph (){
$SPACE > $FILENAME && echo "[CEPH]" >> $FILENAME && $SPACE >> $FILENAME && echo "--- CLUSTER ---" >> $FILENAME && $SPACE >> $FILENAME
cat $FINAL_PATH/ceph/must_gather_commands/ceph_health_detail >> $FILENAME && $SPACE >> $FILENAME
cat $FINAL_PATH/ceph/must_gather_commands/ceph_status >> $FILENAME && $SPACE >> $FILENAME
cat $FINAL_PATH/ceph/must_gather_commands/ceph_df_detail  >> $FILENAME
$SPACE >> $FILENAME && echo "--- DEVICES ---" >> $FILENAME && $SPACE >> $FILENAME
cat $FINAL_PATH/ceph/must_gather_commands/ceph_device_ls  >> $FILENAME
$SPACE >> $FILENAME && echo "--- TREE ---" >> $FILENAME && $SPACE >> $FILENAME
cat $FINAL_PATH/ceph/must_gather_commands/ceph_osd_df_tree >> $FILENAME
$SPACE >> $FILENAME && echo "--- OSD ---" >> $FILENAME && $SPACE >> $FILENAME
egrep ^osd. $FINAL_PATH/ceph/must_gather_commands/ceph_osd_dump | awk '{print $1 "    " $17}' >> $FILENAME
$SPACE >> $FILENAME && echo "--- VERSION ---" >> $FILENAME && $SPACE >> $FILENAME
grep "ceph_version\"" $FINAL_PATH/ceph/must_gather_commands/ceph_service_dump | cut -d : -f 2 >> $FILENAME && $SPACE >> $FILENAME
get_odf
}


function get_odf (){
omg use $FINAL_PATH
echo "[ODF]" >> $FILENAME && $SPACE >> $FILENAME && echo "--- PVC ---" >> $FILENAME && $SPACE >> $FILENAME
$SPACE >> $FILENAME && echo "--- CSV ---" >> $FILENAME && $SPACE >> $FILENAME
cat $FINAL_PATH/namespaces/openshift-storage/oc_output/csv  >> $FILENAME && $SPACE >> $FILENAME
$SPACE >> $FILENAME && echo "--- DEPLOYMENTS---" >> $FILENAME && $SPACE >> $FILENAME
omg get deployments >> $FILENAME && $SPACE >> $FILENAME
$SPACE >> $FILENAME && echo "--- EVENTS ---" >> $FILENAME && $SPACE >> $FILENAME
omg get events >> $FILENAME && $SPACE >> $FILENAME
echo "--- PV ---" >> $FILENAME && $SPACE >> $FILENAME 
echo "NAME                               STATUS  VOLUME                                    CAPACITY  ACCESS MODES  STORAGECLASS                 AGE" >> $FILENAME
omg get pvc |grep deviceset >> $FILENAME && $SPACE >> $FILENAME
#for i in $(omg get pv | grep deviceset | awk '{print $1}') ; do echo $i >> $FILENAME; omg get pv $i -o yaml| grep -Ei " name: | Volumepath" >> $FILENAME; done
for i in $(omg get pv | grep deviceset | awk '{print $1}') ; do echo $i >> $FILENAME; omg get pv $i -o yaml| grep -Ei " kubernetes.io/hostname: | path: " >> $FILENAME; done
$SPACE >> $FILENAME && echo "--- OSD ---" >> $FILENAME && $SPACE >> $FILENAME
omg get pods | grep osd >> $FILENAME && $SPACE >> $FILENAME
for i in $(omg get deployment | grep osd | awk '{print $1}'); do echo $i >> $FILENAME; omg get deployment $i -o yaml | grep "\- devicePath: " | grep -v block >> $FILENAME ; done
}

##########################Main#####################################
main_menu
