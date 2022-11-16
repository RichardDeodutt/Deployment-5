#!/bin/bash

#Richard Deodutt
#09/27/2022
#This script is meant to install the Jenkins agent dependencies on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='agent'

#Home directory
Home='.'

#Log file name
LogFileName="InstallAgent.log"

#The configuration for nginx
ConfigNginx="https://raw.githubusercontent.com/RichardDeodutt/Deployment-3/main/Configs/agent-nginx-default"

#Set the log file location and name
setlogs

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install java if not already
    aptinstalllog "default-jre"
}

#Log start
logokay "Running the install ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the install ${Name} script successfully"

#Exit successs
exit 0