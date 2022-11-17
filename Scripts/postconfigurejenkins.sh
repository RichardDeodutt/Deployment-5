#!/bin/bash

#Richard Deodutt
#10/24/2022
#This script is meant to post configure Jenkins on ubuntu

#Source or import standard.sh
source libstandard.sh

#Name of main target
Name='jenkins'

#Home directory
Home='.'

#Log file name
LogFileName="PostConfigureJenkins.log"

#Set the log file location and name
setlogs

#Replacer python program
ConfigReplacer="https://raw.githubusercontent.com/RichardDeodutt/Deployment-5/main/Utilities/replacer.py"

#The configuration for Jenkins secret
ConfigSecretJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-5/main/Configs/credential-secret-jenkins-default.xml"

#The configuration for Jenkins cred
ConfigCredJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-5/main/Configs/credential-cred-jenkins-default.xml"

#The configuration for Jenkins ssh
ConfigSSHJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-5/main/Configs/credential-ssh-jenkins-default.xml"

#The configuration for Jenkins node
ConfigNodeJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-5/main/Configs/node-jenkins-default.xml"

#The configuration for Jenkins job
ConfigJobJenkins="https://raw.githubusercontent.com/RichardDeodutt/Deployment-5/main/Configs/job-build-jenkins-default.xml"

#The filename of the Replacer python program
ConfigReplacerFileName="replacer.py"

#The filename of the secret configuration file for Jenkins
ConfigSecretJenkinsFileName="credential-secret-jenkins-default.xml"

#The filename of the cred configuration file for Jenkins
ConfigCredJenkinsFileName="credential-cred-jenkins-default.xml"

#The filename of the cred configuration file for Jenkins
ConfigSSHJenkinsFileName="credential-ssh-jenkins-default.xml"

#The filename of the node configuration file for Jenkins
ConfigNodeJenkinsFileName="node-jenkins-default.xml"

#The filename of the job configuration file for Jenkins
ConfigJobJenkinsFileName="job-build-jenkins-default.xml"

#Username
JENKINS_USERNAME=$(cat JENKINS_USERNAME)
#Password
JENKINS_PASSWORD=$(cat JENKINS_PASSWORD)

#AWS_ACCESS_KEY_ID
AWS_ACCESS_KEY_ID=$(cat AWS_ACCESS_KEY_ID)
#Id AWS_ACCESS_KEY_ID
Id_AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"
#Description AWS_ACCESS_KEY_ID
Description_AWS_ACCESS_KEY_ID="AWS_ACCESS_KEY_ID"

#AWS_SECRET_ACCESS_KEY
AWS_SECRET_ACCESS_KEY=$(cat AWS_SECRET_ACCESS_KEY)
#Id AWS_SECRET_ACCESS_KEY
Id_AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"
#Description AWS_SECRET_ACCESS_KEY
Description_AWS_SECRET_ACCESS_KEY="AWS_SECRET_ACCESS_KEY"

#GITHUB_USERNAME
USER_GITHUB_USERNAME=$(cat USER_GITHUB_USERNAME)
#GITHUB_TOKEN
USER_GITHUB_TOKEN=$(cat USER_GITHUB_TOKEN)
#Id GITHUB_CRED
Id_GITHUB_CRED="GITHUB_CRED"
#Description GITHUB_CRED
Description_GITHUB_CRED="GITHUB_CRED"

#JENKINS_JOB_NAME
JENKINS_JOB_NAME=$(cat JENKINS_JOB_NAME)
#JENKINS_GITHUB_REPO_URL
JENKINS_GITHUB_REPO_URL=$(cat JENKINS_GITHUB_REPO_URL)
#JENKINS_GITHUB_REPO_OWNER
JENKINS_GITHUB_REPO_OWNER=$(echo $JENKINS_GITHUB_REPO_URL | cut -d "/" -f4)
#JENKINS_GITHUB_REPO_NAME
JENKINS_GITHUB_REPO_NAME=$(echo $JENKINS_GITHUB_REPO_URL | cut -d "/" -f5 | sed 's/.git//')

#JENKINS_SSH_KEY
JENKINS_SSH_KEY=$(cat JENKINS_SSH_KEY)
#Username JENKINS_SSH_KEY
Username_JENKINS_SSH_KEY="ubuntu"
#Id JENKINS_SSH_KEY
Id_JENKINS_SSH_KEY="SSH"
#Description JENKINS_SSH_KEY
Description_JENKINS_SSH_KEY="SSH"

#Host Terraform
Host_Terraform=$(cat TERRAFORM_IP)
#Label Terraform
Label_Terraform="Terraform"
#Name Terraform
Name_Terraform="Terraform"
#Description Terraform
Description_Terraform="Terraform"

#Host Docker
Host_Terraform=$(cat DOCKER_IP)
#Label Docker
Label_Terraform="Docker"
#Name Docker
Name_Terraform="Docker"
#Description Docker
Description_Terraform="Docker"

#Store the initial secret config for Jenkins here
LoadedInitialConfigJenkins=""

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

    #Download jenkins-cli.ja if not already
    ls $ConfigReplacerFileName > /dev/null 2>&1 && logokay "Successfully found $ConfigReplacerFileName for ${Name}" || { curl -s $ConfigReplacer -O -J && ls $ConfigReplacerFileName > /dev/null 2>&1 && logokay "Successfully downloaded $ConfigReplacerFileName for ${Name}" || { logerror "Failure obtaining $ConfigReplacerFileName for ${Name}" && exiterror ; } ; }

    #Start the service if not already
    systemctl start jenkins > /dev/null 2>&1 && logokay "Successfully started ${Name}" || { logerror "Failure starting ${Name}" && exiterror ; }

    #Get the Jenkins secret configure file
    curl -s -X GET $ConfigSecretJenkins -O && logokay "Successfully obtained secret configure file for ${Name}" || { logerror "Failure obtaining secret configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigSecretJenkinsFileName) && logokay "Successfully loaded secret configure file for ${Name}" || { logerror "Failure loading secret configure file for ${Name}" && exiterror ; }

    #Set the ID, Description and secret for the secret configure file placeholders for AWS_ACCESS_KEY_ID
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_AWS_ACCESS_KEY_ID/g" | sed "s/~Description~/$Description_AWS_ACCESS_KEY_ID/g" | sed "s,~Secret~,$AWS_ACCESS_KEY_ID,g" > $ConfigSecretJenkinsFileName && logokay "Successfully set secret configure file for ${Name} AWS_ACCESS_KEY_ID" || { logerror "Failure setting secret configure file for ${Name} AWS_ACCESS_KEY_ID" && exiterror ; }

    #Remote send the secret config AWS_ACCESS_KEY_ID
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigSecretJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send secret config for ${Name} AWS_ACCESS_KEY_ID" || { test $? -eq 1 && logwarning "Secret config for ${Name} AWS_ACCESS_KEY_ID already exists nothing changed" || { logerror "Failure executing send secret config for ${Name} AWS_ACCESS_KEY_ID" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Get the Jenkins secret configure file
    curl -s -X GET $ConfigSecretJenkins -O && logokay "Successfully obtained secret configure file for ${Name}" || { logerror "Failure obtaining secret configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigSecretJenkinsFileName) && logokay "Successfully loaded secret configure file for ${Name}" || { logerror "Failure loading secret configure file for ${Name}" && exiterror ; }

    #Set the ID, Description and secret for the secret configure file placeholders for AWS_SECRET_ACCESS_KEY
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_AWS_SECRET_ACCESS_KEY/g" | sed "s/~Description~/$Description_AWS_SECRET_ACCESS_KEY/g" | sed "s,~Secret~,$AWS_SECRET_ACCESS_KEY,g" > $ConfigSecretJenkinsFileName && logokay "Successfully set secret configure file for ${Name} AWS_SECRET_ACCESS_KEY" || { logerror "Failure setting secret configure file for ${Name} AWS_SECRET_ACCESS_KEY" && exiterror ; }

    #Remote send the secret config AWS_SECRET_ACCESS_KEY
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigSecretJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send secret config for ${Name} AWS_SECRET_ACCESS_KEY" || { test $? -eq 1 && logwarning "Secret config for ${Name} AWS_SECRET_ACCESS_KEY already exists nothing changed" || { logerror "Failure executing send secret config for ${Name} AWS_SECRET_ACCESS_KEY" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove secret configure file
    rm $ConfigSecretJenkinsFileName && logokay "Successfully removed secret configure file for ${Name}" || { logerror "Failure removing secret configure file for ${Name}" && exiterror ; }

    #Get the Jenkins cred configure file
    curl -s -X GET $ConfigCredJenkins -O && logokay "Successfully obtained cred configure file for ${Name}" || { logerror "Failure obtaining cred configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigCredJenkinsFileName) && logokay "Successfully loaded cred configure file for ${Name}" || { logerror "Failure loading cred configure file for ${Name}" && exiterror ; }

    #Set the ID, Description, Username and Password for the cred configure file placeholders for GITHUB_CRED
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_GITHUB_CRED/g" | sed "s/~Description~/$Description_GITHUB_CRED/g" | sed "s,~Username~,$USER_GITHUB_USERNAME,g" | sed "s,~Password~,$USER_GITHUB_TOKEN,g" > $ConfigCredJenkinsFileName && logokay "Successfully set cred configure file for ${Name} GITHUB_CRED" || { logerror "Failure setting cred configure file for ${Name} GITHUB_CRED" && exiterror ; }

    #Remote send the cred config GITHUB_CRED
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigCredJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send cred config for ${Name} GITHUB_CRED" || { test $? -eq 1 && logwarning "Cred config for ${Name} GITHUB_CRED already exists nothing changed" || { logerror "Failure executing send cred config for ${Name} GITHUB_CRED" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove cred configure file
    rm $ConfigCredJenkinsFileName && logokay "Successfully removed cred configure file for ${Name}" || { logerror "Failure removing cred configure file for ${Name}" && exiterror ; }

    #Get the Jenkins SSH configure file
    curl -s -X GET $ConfigSSHJenkins -O && logokay "Successfully obtained SSH configure file for ${Name}" || { logerror "Failure obtaining SSH configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigSSHJenkinsFileName) && logokay "Successfully loaded SSH configure file for ${Name}" || { logerror "Failure loading SSH configure file for ${Name}" && exiterror ; }

    #Set the ID, Description, Username and SSH-Key for the SSH configure file placeholders for SSH
    echo "$LoadedInitialConfigJenkins" | sed "s/~Id~/$Id_JENKINS_SSH_KEY/g" | sed "s/~Description~/$Description_JENKINS_SSH_KEY/g" | sed "s,~Username~,$Username_JENKINS_SSH_KEY,g" > $ConfigSSHJenkinsFileName && logokay "Successfully set SSH configure file for ${Name} SSH" || { logerror "Failure setting SSH configure file for ${Name} SSH" && exiterror ; }

    #Set the SSH-Key for the SSH configure file placeholders for SSH
    python3 $ConfigReplacerFileName $ConfigSSHJenkinsFileName $ConfigSSHJenkinsFileName ~SSH-Key~ "$JENKINS_SSH_KEY" && logokay "Successfully set SSH configure file for ${Name} SSH-Key" || { logerror "Failure setting SSH configure file for ${Name} SSH-Key" && exiterror ; }

    #Remote send the SSH config SSH
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-credentials-by-xml system::system::jenkins _ < $ConfigSSHJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send SSH config for ${Name} SSH" || { test $? -eq 1 && logwarning "SSH config for ${Name} SSH already exists nothing changed" || { logerror "Failure executing send SSH config for ${Name} SSH" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove SSH configure file
    rm $ConfigSSHJenkinsFileName && logokay "Successfully removed SSH configure file for ${Name}" || { logerror "Failure removing SSH configure file for ${Name}" && exiterror ; }

    #Get the Jenkins node configure file
    curl -s -X GET $ConfigNodeJenkins -O && logokay "Successfully obtained node configure file for ${Name}" || { logerror "Failure obtaining node configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigNodeJenkinsFileName) && logokay "Successfully loaded node configure file for ${Name}" || { logerror "Failure loading node configure file for ${Name}" && exiterror ; }

    #Set the Name, Description, Label, Host and CredentialsId for the node configure file placeholders for Terraform
    echo "$LoadedInitialConfigJenkins" | sed "s/~Name~/$Name_Terraform/g" | sed "s/~Description~/$Description_Terraform/g" | sed "s,~Label~,$Label_Terraform,g" | sed "s,~Host~,$Host_Terraform,g" | sed "s,~CredentialsId~,$Id_JENKINS_SSH_KEY,g" > $ConfigNodeJenkinsFileName && logokay "Successfully set node configure file for ${Name} Terraform" || { logerror "Failure setting node configure file for ${Name} Terraform" && exiterror ; }

    #Remote send the node config GITHUB_CRED
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-node $Name_Terraform < $ConfigNodeJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send node config for ${Name} Terraform" || { test $? -eq 1 && logwarning "Node config for ${Name} Terraform already exists nothing changed" || { logerror "Failure executing send node config for ${Name} Terraform" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove node configure file
    rm $ConfigNodeJenkinsFileName && logokay "Successfully removed node configure file for ${Name}" || { logerror "Failure removing node configure file for ${Name}" && exiterror ; }

    #Get the Jenkins node configure file
    curl -s -X GET $ConfigNodeJenkins -O && logokay "Successfully obtained node configure file for ${Name}" || { logerror "Failure obtaining node configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigNodeJenkinsFileName) && logokay "Successfully loaded node configure file for ${Name}" || { logerror "Failure loading node configure file for ${Name}" && exiterror ; }

    #Set the Name, Description, Label, Host and CredentialsId for the node configure file placeholders for Docker
    echo "$LoadedInitialConfigJenkins" | sed "s/~Name~/$Name_Docker/g" | sed "s/~Description~/$Description_Docker/g" | sed "s,~Label~,$Label_Docker,g" | sed "s,~Host~,$Host_Docker,g" | sed "s,~CredentialsId~,$Id_JENKINS_SSH_KEY,g" > $ConfigNodeJenkinsFileName && logokay "Successfully set node configure file for ${Name} Docker" || { logerror "Failure setting node configure file for ${Name} Docker" && exiterror ; }

    #Remote send the node config GITHUB_CRED
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-node $Name_Docker < $ConfigNodeJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send node config for ${Name} Docker" || { test $? -eq 1 && logwarning "Node config for ${Name} Docker already exists nothing changed" || { logerror "Failure executing send node config for ${Name} Docker" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove node configure file
    rm $ConfigNodeJenkinsFileName && logokay "Successfully removed node configure file for ${Name}" || { logerror "Failure removing node configure file for ${Name}" && exiterror ; }

    #Get the Jenkins job configure file
    curl -s -X GET $ConfigJobJenkins -O && logokay "Successfully obtained job configure file for ${Name}" || { logerror "Failure obtaining job configure file for ${Name}" && exiterror ; }

    #Load the initial configuration for Jenkins
    LoadedInitialConfigJenkins=$(cat $ConfigJobJenkinsFileName) && logokay "Successfully loaded job configure file for ${Name}" || { logerror "Failure loading job configure file for ${Name}" && exiterror ; }

    #Set the RepoOwner, RepoName and RepoURL for the job configure file placeholders
    echo "$LoadedInitialConfigJenkins" | sed "s,~RepoOwner~,$JENKINS_GITHUB_REPO_OWNER,g" | sed "s,~RepoName~,$JENKINS_GITHUB_REPO_NAME,g" | sed "s,~RepoURL~,$JENKINS_GITHUB_REPO_URL,g" > $ConfigJobJenkinsFileName && logokay "Successfully set job configure file for ${Name}" || { logerror "Failure setting job configure file for ${Name}" && exiterror ; }

    #Remote send the job config
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD create-job $JENKINS_JOB_NAME < $ConfigJobJenkinsFileName > JenkinsExecution 2>&1 && logokay "Successfully executed send job config for ${Name}" || { test $? -eq 4 && logwarning "Job config for ${Name} already exists nothing changed" || { logerror "Failure executing send job config for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    logokay "Waiting for job Initialization" && sleep 30

    #Remote send stop the auto build if any
    java -jar $JCJ -s "http://localhost:8080" -http -auth $JENKINS_USERNAME:$JENKINS_PASSWORD stop-builds $JENKINS_JOB_NAME/main > JenkinsExecution 2>&1 && logokay "Successfully executed stop bulid jobs for ${Name}" || { test $? -eq 3 && logwarning "Job not found to stop" || { logerror "Failure executing stop bulid jobs for ${Name}" && cat JenkinsExecution && rm JenkinsExecution && exiterror ; } ; }

    #Remove job configure file
    rm $ConfigJobJenkinsFileName && logokay "Successfully removed job configure file for ${Name}" || { logerror "Failure removing job configure file for ${Name}" && exiterror ; }
}

#Log start
logokay "Running the post configure ${Name} script"

#Check for admin permissions
admincheck

#Call the main function
main

#Log successs
logokay "Ran the post configure ${Name} script successfully"

#Exit successs
exit 0