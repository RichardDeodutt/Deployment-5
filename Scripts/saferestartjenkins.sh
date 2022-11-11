#!/bin/bash

#Richard Deodutt
#10/25/2022
#This script is meant to safe restart Jenkins on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='jenkins'

#Home directory
Home='.'

#Log file name
LogFileName="SafeRestartJenkins.log"

#Set the log file location and name
setlogs

#Username
JENKINS_USERNAME=$(cat JENKINS_USERNAME)
#Password
JENKINS_PASSWORD=$(cat JENKINS_PASSWORD)

#List of pending jobs
PendingJobs="Some Jobs"

#Start Time of waiting or plugins to install
StartEpoch="Unset"

#Retry or sleep delay in seconds
Retry=15

#Timeout in seconds, 10 minutes
Timeout=600

#Jenkins cli jar file name
JCJ="jenkins-cli.jar"

#The main function
main(){
    #Update local apt repo database
    aptupdatelog

    #Install jq if not already
    aptinstalllog "jq"

    #Install curl if not already
    aptinstalllog "curl"

    #Download jenkins-cli.ja if not already
    ls $JCJ > /dev/null 2>&1 && logokay "Successfully found $JCJ for ${Name}" || { curl -s "http://localhost:8080/jnlpJars/jenkins-cli.jar" -O -J && ls $JCJ > /dev/null 2>&1 && logokay "Successfully downloaded $JCJ for ${Name}" || { logerror "Failure obtaining $JCJ for ${Name}" && exiterror ; } ; }

    #Start the service if not already
    systemctl start jenkins > /dev/null 2>&1 && logokay "Successfully started ${Name}" || { logerror "Failure starting ${Name}" && exiterror ; }

    #Get a Jenkins crumb and a session cookie
    curl -s -c JenkinsSessionCookie -X GET "http://localhost:8080/crumbIssuer/api/json" --user $JENKINS_USERNAME:$JENKINS_PASSWORD | jq -r .crumb > JenkinsLastCrumb && logokay "Successfully obtained a crumb and a session cookie for ${Name}" || { logerror "Failure obtaining crumb and a session cookie for ${Name}" && exiterror ; }

    #Set the start time of waiting
    StartEpoch=$(date +%s)

    logokay "Checking jobs for ${Name}"

    #Wait until all jobs are completed
    while [ -n "$PendingJobs" ]; do

    sleep $Retry

    #Remote check the updateCenter jobs, refresh jobs and store to file
    curl -s -g -b JenkinsSessionCookie -X GET "http://localhost:8080/updateCenter/api/json?tree=jobs[*]" -H "Jenkins-Crumb: $(cat JenkinsLastCrumb)" --user $JENKINS_USERNAME:$JENKINS_PASSWORD | jq -r '. | .jobs | .[].status._class? // empty' | sed 's/hudson.model.UpdateCenter$DownloadJob$SuccessButRequiresRestart//g' | sed 's/hudson.model.UpdateCenter$DownloadJob$Success//g' | sed '/^$/d' > JenkinsExecution 2>&1 && logokay "Successfully checked jobs for ${Name} $(printwarning $(cat JenkinsExecution | wc -l)) $(printokay 'jobs left')" || { logerror "Failure checking jobs for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; }

    #Store the pending jobs as a variable and refresh it
    PendingJobs=$(cat JenkinsExecution)

    #Check if we timed out
    if [ $(date +%s) -ge $(echo "$StartEpoch + $Timeout" | bc) ]; then

        #Exit if it times out
        logerror "Timedout waitig for all jobs for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ;

    fi

    done

    #Remote do a safe restart
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD safe-restart > JenkinsExecution 2>&1 && logokay "Successfully executed safe restart for ${Name}" || { logerror "Failure executing safe restart for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; }
}

#Log start
logokay "Running the safe restart ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the safe restart ${Name} script successfully"

#Exit successs
exit 0