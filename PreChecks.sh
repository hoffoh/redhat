#!/bin/bash
# Script to get report from pre-checks after upgrade, manual intervention is required this only summarizes some info not checking all the data
#Version 1
######################Vars###################################
clear
SPACE="echo " 
LINE="echo -------------------------------------------------------------------------------------------------------"

##################Functions##################################

function main_menu (){
get_case
FILE="$CASENUM"_Pre.out && get_data
echo $FILE
}

function get_case (){
clear
$LINE
echo "-                                   List of cases downloaded                                          -"
GETCASES=`ls -ltr ~ | grep cases | cut -d "/" -f 3`
if [[ -z ${GETCASES} ]]
then
  echo -e "$LINE"
  echo -e "NO CASES FOUND ON THE DIRECTORY""\0033[0m"
else
  $LINE
  for n in $(echo $GETCASES)
  do  
    echo "-    $n" 
  done
fi
$LINE && $LINE
read -p " Case Number:> " CASENUM
}

function print_space(){
echo '' >> $FILE
}

function get_data (){
$LINE && $SPACE && echo "Looking for ODF must-gathers on case: $CASENUM" && $SPACE && $LINE
MGSUBPATH=$(find  ~/$CASENUM/ -maxdepth 3 -type d | grep -E "odf-must-gather|ocs-must-gather")
 
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
    $LINE
    read -p "  Insert absolute path from above for the report :> " FINAL_PATH
    CEPH_FINAL_PATH=$FINAL_PATH/ceph/must_gather_commands
    $LINE
fi
get_ceph
}

function get_ceph (){
echo '' > $FILE
echo "[CEPH]" >> $FILE && print_space && echo "--- CLUSTER ---" >> $FILE && print_space
cat $CEPH_FINAL_PATH/ceph_health_detail >> $FILE && print_space
cat $CEPH_FINAL_PATH/ceph_status >> $FILE && print_space
cat $CEPH_FINAL_PATH/ceph_df_detail  >> $FILE
print_space && echo "--- DEVICES ---" >> $FILE && print_space
cat $CEPH_FINAL_PATH/ceph_device_ls  >> $FILE
print_space && echo "--- TREE ---" >> $FILE && print_space
cat $CEPH_FINAL_PATH/ceph_osd_df_tree >> $FILE
print_space && echo "--- OSD ---" >> $FILE && print_space
egrep ^osd. $CEPH_FINAL_PATH/ceph_osd_dump | awk '{print $1 "    " $17}' >> $FILE
print_space && echo "--- VERSION ---" >> $FILE && print_space
grep "ceph_version\"" $CEPH_FINAL_PATH/ceph_service_dump | cut -d : -f 2 >> $FILE && print_space
get_odf
}

function get_odf (){
omg use $FINAL_PATH
echo "[ODF]" >> $FILE && print_space && echo "--- PVC ---" >> $FILE && print_space
omg get pvc >> $FILE
print_space && echo "--- CSV ---" >> $FILE && print_space
cat $FINAL_PATH/namespaces/openshift-storage/oc_output/csv  >> $FILE && print_space
print_space && echo "--- DEPLOYMENTS---" >> $FILE && print_space
omg get deployments >> $FILE && print_space
print_space && echo "--- EVENTS ---" >> $FILE && print_space
omg get events >> $FILE && print_space
echo "--- PV ---" >> $FILE && print_space 
omg get pvc | head -n 1 >> $FILE
omg get pvc |grep deviceset >> $FILE && print_space
for i in $(omg get pv | grep deviceset | awk '{print $1}'); do 
  echo $i >> $FILE
  omg get pv $i -o yaml| grep -Ei " kubernetes.io/hostname: | path: | Volumepath| driver:" >> $FILE
done
print_space && echo "--- OSD ---" >> $FILE && print_space
omg get pods | grep osd >> $FILE && print_space
for i in $(omg get deployment | grep osd | awk '{print $1}'); do
  echo $i >> $FILE
  omg get deployment $i -o yaml | grep "\- devicePath:" | grep -v block >> $FILE 
  omg get deployment $i -o yaml | grep " claimName" >> $FILE 
done
}

##########################Main#####################################
main_menu
