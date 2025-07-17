# Scripts to help troubleshooting Rafrojas

NOTE: If you find any issue running them please reach me at rafrojas@redhat.com

# Used on supportshell

### To generate a glusterfs report of the cluster

    - bash ./checksos.sh

Will scan home directory for case numbers and give a list, you need to select the case to get a list of sos-reports, finally select the number of the report to get data

### To generate a Ceph/ODF report of general status 

    - bash ./PreChecks.sh

Collect ODF/CEPH data from ODF must-gather, copy paste the absolut path to get data from selected ODF Must gather on the case

* If you provides argument with the path of the must-gather it will go through the directory after confirm the case number to create the report

  #> PreChecks.sh 0010-must-gather.local.4638465044622777996.tar.gz/must-gather.local.4638465044622777996/inspect.local.1261512429828137083

# Share with customer 

## Share with customer below scripts to collect Ceph data from operator/toolbox or ODF data when must-gather is failing:

### Scripts to generate a report from Ceph:

  Using rook-ceph-operator pod:

    - bash get_ceph_info_operator.sh

  Using rook-ceph-toolbox pod:

    - bash get_ceph_info_toolbox.sh



## Script to generate a report from ODF:

    - bash get_odf_info.sh

## Script to generate a report from Local Storage Operator on a node:

    - bash get_lso_info.sh

Script is created assuming that you have devices named /dev/sdX , you need to change the head command on the script if are different (Ex. vda,vdb...)

### OSD Symlink Scripts ###

  To be used with OC cli, generally on customer clusters or internal labs running oc command

    - get_osd_symlinks.sh

  To be used on Suportshell, will use OMC binary with the data currently being used by this binary

    - get_osd_symlinks_internal.sh
