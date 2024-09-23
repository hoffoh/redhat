#Red hat non official bash scripts developed to help troubleshooting issues by Rafa Rojas


# Those scripts are used to get a summary from sos-report or ODF Must-gathers by running the script

Usage:

Used on supportshell where the cases are yanked

    - bash ./checksos.sh

Will scan home directory for case numbers and give a list, you need to select the case to get a list of sos-reports, finally select the number of the report to get data

    - bash ./PreChecks.sh

Collect ODF/CEPH data from ODF must-gather, copy paste the absolut path to get data from selected ODF Must gather on the case


# Share with customer below scripts to collect Ceph data from operator/toolbox or ODF data:


# Scripts to collect data from Ceph:

  Using rook-ceph-operator pod:

    - bash get_ceph_info_operator.sh

  Using rook-ceph-toolbox pod:

get_ceph_info_toolbox.sh


# Script to collect data from ODF:

    - bash get_odf_info.sh


# Script to collect Local Storage Operator details from a node:

    - bash get_lso_info.sh
