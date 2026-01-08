#!/bin/bash
# Script to get report from pre-checks after upgrade from Ceph and ODF
# Manual intervention is required (case num and ODF MG Path) this only summarizes some info not checking all the data
# You can force to run on a path by entering the path as argument 
# Version 2
######################Vars###################################
clear
SPACE="echo " 
LINE="echo -------------------------------------------------------------------------------------------------------"
TITLES=("HEALTH" "DEVICES" "TREE" "OSD" "VERSION" "PVC" "CSV" "DEPLOYMENTS" "EVENTS" "PV" "OSD" "DETAIL" "HISTORY" "JOBS")
MANUALPATH=$1
CEPH_CMD=("ceph_health_detail" "ceph_status" "ceph_df_detail" "ceph_device_ls" "ceph_osd_df_tree" "ceph_versions")
OSD_HISTORY="cluster-scoped-resources/config.openshift.io/clusterversions/version.yaml"
##################Functions##################################

function main_menu (){
get_case
FILE="$CASENUM"_Pre.out && get_data
$LINE && $SPACE && echo "Ceph path: $CEPH_FINAL_PATH" &&  echo "ODF path: $FINAL_PATH" && $SPACE
echo "File: $FILE" && $SPACE
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

function print_title(){
echo '' >> $FILE ; echo "--- ${TITLES[$X]} ---" >> $FILE ; echo '' >> $FILE
}

function print_ceph(){
cat $CEPH_FINAL_PATH/${CEPH_CMD[$Y]} >> $FILE

}

function get_data (){
$LINE && $SPACE && echo "Looking for ODF must-gathers on case: $CASENUM" && $SPACE && $LINE
MGSUBPATH=$(find  ~/$CASENUM/ -maxdepth 3 -type d | grep -E "odf4-odf-must-gather|ocs-must-gather" | grep -Ev "ceph$|resources$|namespaces$|noobaa$|\.zip$" | sort )

if [[ -n "$MANUALPATH" ]]
  then
    MGSUBPATH="/cases/$CASENUM/$MANUALPATH"
    FINAL_PATH="/cases/$CASENUM/$MANUALPATH"
    CEPH_FINAL_PATH="$FINAL_PATH/ceph/must_gather_commands"
    get_ceph
    $LINE &&  $SPACE && echo "Ceph path: $CEPH_FINAL_PATH" &&  echo "ODF path: $MGSUBPATH" && $SPACE
    echo "File: $FILE" && $SPACE
    exit 0
fi

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
echo '' > $FILE ; echo "[CEPH]" >> $FILE
X=11;print_title
Y=0;print_ceph
X=0;print_title
Y=1;print_ceph
Y=2;print_ceph
X=2;print_title
Y=4;print_ceph
X=1;print_title
Y=3;print_ceph
X=3;print_title
egrep ^osd. $CEPH_FINAL_PATH/ceph_osd_dump | awk '{print $1 "    " $17}' >> $FILE
X=4;print_title
Y=5;print_ceph;print_space
get_odf
}

function get_odf (){
omg use $FINAL_PATH
echo "[ODF]" >> $FILE
X=12;print_title
cat $FINAL_PATH/$OSD_HISTORY | grep -A200 " history:" | grep -Ei " version:|completion" >> $FILE && print_space
X=13;print_title
omg get jobs>> $FILE
X=6;print_title
cat $FINAL_PATH/namespaces/openshift-storage/oc_output/csv  >> $FILE && print_space
X=7;print_title
omg get deployments >> $FILE && print_space
X=8;print_title
omg get events >> $FILE
X=9;print_title
omg get pvc | head -n 1 >> $FILE
omg get pvc |grep deviceset >> $FILE && print_space
for i in $(omg get pv | grep deviceset | awk '{print $1}'); do 
  echo $i >> $FILE
  omg get pv $i -o yaml| grep -Ei " kubernetes.io/hostname: | path: | Volumepath| driver:" >> $FILE
done
X=10;print_title
omg get pods -o wide | grep osd >> $FILE && print_space
for i in $(omg get deployment | grep osd | awk '{print $1}'); do
  echo $i >> $FILE
  omg get deployment $i -o yaml | grep "\- devicePath:" | grep -v block >> $FILE 
  omg get deployment $i -o yaml | grep " claimName" >> $FILE 
  omg get deployment $i -o yaml | grep -EA1 " ROOK_CV_MODE$" >> $FILE 
done
}

##########################Main#####################################
main_menu
