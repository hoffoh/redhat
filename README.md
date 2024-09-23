# Scripts to help troubleshooting issues by Rafrojas

## Those scripts are used locally to get a summary from sos-report or ODF Must-gathers by running the script:

Usage:

Used on supportshell where the cases are yanked

### To generate a glusterfs report of the cluster

    - bash ./checksos.sh

Will scan home directory for case numbers and give a list, you need to select the case to get a list of sos-reports, finally select the number of the report to get data

### To generate a Ceph/ODF report of general status 

    - bash ./PreChecks.sh

Collect ODF/CEPH data from ODF must-gather, copy paste the absolut path to get data from selected ODF Must gather on the case


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
