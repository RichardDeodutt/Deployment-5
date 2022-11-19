# Deployment-5

Set up a CI/CD pipeline from start to finish using a Jenkins server and Agents to deploy with Terraform a containerized application using Docker Images created with a Dockerfile. 

My goal was to automate as much as I can, from setting up an ec2 with a Jenkins server all the way to having it do a build on the jenkins server. 

To achieve this goal I used Github, Github Actions, GitHub Secrets, Terraform and some Bash and Python scripting. 

I containerized a full stack app. This app has a React frontend, a Flask API backend and a MySQL database. 

I used Adminer to connect to and manage the database and Nginx for the reverse proxy to access the other containers. 

# Process

## The First Step

<details>

<summary>Create an EC2 with Jenkins installed and the Agents</summary>

<br>

- I used a GitHub Actions work flow to achieve this along with GitHub Secrets to create variables and pass arugments or replace place holders such as `~User~`. 

- The workflow [Deploy-Pipeline](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Deploy-Pipeline.yml) will use the terraform files for [Pipeline](https://github.com/RichardDeodutt/Deployment-5/tree/main/Terraform/Pipeline) to create a EC2 and install Jenkins along with everything the server should have doing the initial setup. It does the same for the Agents. It uses `SSH` and [Bash scripts](https://github.com/RichardDeodutt/Deployment-5/tree/main/Scripts) to install Jenkins and the other software needed. This assumes you already have a `keypair` created and a `security group` with port `22` and `80` open to use. You need to set the `keypair` and `security group` names in the terraform files to yours along with using your `region`. This can be done by setting the secrets: `BUCKET_NAME`, `TABLE_NAME`, `AWS_REGION`, `AWS_AMI`, `AWS_ITYPE`, `AWS_KEYNAME` and `AWS_SECGROUPNAME`. The secrets will replace the placeholders using the [replacer](https://raw.githubusercontent.com/RichardDeodutt/Deployment-5/main/Utilities/replacer.py) when run by the workflow. 

- To store the state file I used a `S3 bucket` and a `Dynamodb table` to store a `statelock`. There are more terraform files for the [Backend](https://github.com/RichardDeodutt/Deployment-5/tree/main/Terraform/Remote-S3) to create it but this needs to be changed to be `unique`, it can't be the same as mine. I created the workflow [Init-Remote-Statefile](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Init-Remote-Statefile.yml) to initialize the backend. Setting the secrets: `BUCKET_NAME`, `TABLE_NAME` and `AWS_REGION` to yours will allow it to function correctly. 

- Using the state file I created a workflow [Release-Jenkins](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Release-Jenkins.yml) to `destroy` the infrastructure when done with it. 

- I created a workflow [Redeploy-Jenkins](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Redeploy-Jenkins.yml) to saved time if I wanted to `restart from scratch` by first `destroying` the infrastructure and then `creating` it again. It `recreates` everything from scratch. 

- The workflows that deploy the Jenkins server do some inital configurations using the Jenkins API, Jenkins CLI and a generated [Groovy script](https://github.com/RichardDeodutt/Deployment-5/blob/main/Configs/jenkins-configure.groovy) to setup things such as the username, password and plugins. 

- (Nginx)[https://github.com/RichardDeodutt/Deployment-5/blob/main/Configs/server-nginx-default] is used as a reverse proxy to use port 80. 

</details>

## The Second Step

<details>

<summary>Configure the Jenkins Server</summary>

<br>

- I created a workflow [Post-Config-Jenkins](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Post-Config-Jenkins.yml) to configure Jenkins so you don't have to use the web UI. It uses SSH to run scripts that uses the Jenkins CLI and some [xml templates](https://github.com/RichardDeodutt/Deployment-5/tree/main/Configs).

- It creates the [Secrets](https://github.com/RichardDeodutt/Deployment-5/blob/main/Configs/credential-secret-jenkins-default.xml), [Credentials](https://github.com/RichardDeodutt/Deployment-5/blob/main/Configs/credential-cred-jenkins-default.xml), [SSH-Key](https://github.com/RichardDeodutt/Deployment-5/blob/main/Configs/credential-ssh-jenkins-default.xml), [Nodes or Agents](https://github.com/RichardDeodutt/Deployment-5/blob/main/Configs/node-jenkins-default.xml) and also the [build job or project](https://github.com/RichardDeodutt/Deployment-5/blob/main/Configs/job-build-jenkins-default.xml) for Deployment-5 while making sure it `dosn't run automatically` by canceling the first auto build. 

</details>

## The Third Step

<details>

<summary>Control the Jenkins Server</summary>

<br>

- I made a workflow [Execute-Jenkins-Build-Job](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Execute-Jenkins-Build-Job.yml) that allows me to run the `build job`  without using the web UI all from the `Github Actions` page. I could use a `webhook` and `update` the `forked repository` to automatically have it `build` but this workflow gived me the ability to run the build `whenever` I want. 

- I also made a workflow [Update-Forked-Repo](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Update-Forked-Repo.yml) that allow me to automatically update the forked repo with the changes in the [Modified-Application-Files](https://github.com/RichardDeodutt/Deployment-5/tree/main/Modified-Application-Files) directory. I make the changes `manually` to `Modified-Application-Files` and once this repository is `updated` I can run this workflow to `update` the `forked` repository automatically. It only overwrites existing files and won't delete existing files in the forked repo for safety. 

- There is also a workflow [Build-and-Test](https://github.com/RichardDeodutt/Deployment-5/blob/main/.github/workflows/Build-and-Test.yml) I made to do unit tests on the scripts to make sure they don't break accidentally. 

- The scripts in the [Runners](https://github.com/RichardDeodutt/Deployment-5/tree/main/Runners) directory run the scrips in the [Scripts](https://github.com/RichardDeodutt/Deployment-5/tree/main/Scripts) directory. 

</details>

# Secrets/Variables

<details>

<summary>Show Secrets/Variables</summary>

<br>

- AWS_ACCESS_KEY_ID 

    - AWS IAM User with AdministratorAccess, their Access Key ID. 

        Secrets/Variables:

        ```
        AWS_ACCESS_KEY_ID
        ```

        Example Below: 

        ```
        AKIAXIDF5EYC4GKLMXNZ
        ```

- AWS_SECRET_ACCESS_KEY 

    - AWS IAM User with AdministratorAccess, their Secret Access Key ID. 

        Secrets/Variables:

        ```
        AWS_SECRET_ACCESS_KEY
        ```

        Example Below: 

        ```
        nhsi9mxRJfZYUx/HKS4jJ1rK4tcbJwH+pzg3I+nD
        ```

- AWS_SSH_KEY_BASE64 

    - AWS SSH Key Pair to SSH into the Jenkins Server and Agents EC2 in base64 format using the base64 command. 

        Secrets/Variables:

        ```
        AWS_SSH_KEY_BASE64
        ```

        Example Below: 

        ```
        cat ~/.ssh/Tokyo.pem | base64
        ```

- JENKINS_USERNAME 

    - Desired Jenkins username to create the Jenkins Server with. 

        Secrets/Variables:

        ```
        JENKINS_USERNAME
        ```

        Example Below: 

        ```
        Jeff
        ```

- JENKINS_PASSWORD 

    - Desired Jenkins password to create the Jenkins Server with. 

        Secrets/Variables:

        ```
        JENKINS_PASSWORD
        ```

        Example Below: 

        ```
        password1234
        ```

- JENKINS_EMAIL 

    - Desired Jenkins admin email to create the Jenkins Server with. 

        Secrets/Variables:

        ```
        JENKINS_EMAIL
        ```

        Example Below: 

        ```
        Jeff@gmail.com
        ```

- USER_GITHUB_USERNAME 

    - Your Github Username to access your forked repo. 

        Secrets/Variables:

        ```
        USER_GITHUB_USERNAME
        ```

        Example Below: 

        ```
        BossJeff
        ```

- USER_GITHUB_TOKEN 

    - Your Github Personal Access token to access your forked repo. 

        Secrets/Variables:

        ```
        USER_GITHUB_TOKEN
        ```

        Example Below: 

        ```
        ghp_l5W2WQ0vrQIOaNmApxv2ygBIvDXoxj2EllWd
        ```

- JENKINS_JOB_NAME 

    - The name of the Build Job or Project Jenkins uses. Must contain no spaces or dots. 

        Secrets/Variables:

        ```
        JENKINS_JOB_NAME
        ```

        Example Below: 

        ```
        Deployment-5
        ```

- JENKINS_GITHUB_REPO_URL 

    - The url of the forked repo. 

        Secrets/Variables:

        ```
        JENKINS_GITHUB_REPO_URL
        ```

        Example Below: 

        ```
        https://github.com/RichardDeodutt/kuralabs_deployment_4
        ```

- THIS_GITHUB_REPO_URL

    - The url of this repo or if this is a fork of the original then the url of this forked repo. 

        Secrets/Variables:

        ```
        THIS_GITHUB_REPO_URL
        ```

        Example Below: 

        ```
        https://github.com/RichardDeodutt/Deployment-5
        ```

- USER_GITHUB_SSH_KEY_BASE64

    - Your GitHub SSH key to do a push in base64 format using the base64 command. 

        Secrets/Variables:

        ```
        USER_GITHUB_SSH_KEY_BASE64
        ```

        Example Below: 

        ```
        cat ~/.ssh/id_rsa | base64
        ```

- USER_GITHUB_EMAIL

    - Your GitHub email to author a commit can be the same as the JENKINS_EMAIL. 

        Secrets/Variables:

        ```
        USER_GITHUB_EMAIL
        ```

        Example Below: 

        ```
        Jeff@gmail.com
        ```

- BUCKET_NAME

    - Your S3 bucket name for storing the Terraform statefile. Must not be already generated and contain no spaces or dots. 

        Secrets/Variables:

        ```
        BUCKET_NAME
        ```

        Example Below: 

        ```
        terraform-remote-statefile-store-d10
        ```

- TABLE_NAME

    - Your DynamoDB table name for storing the lockfile of the Terraform statefile. Must not be already generated and contain no spaces or dots. 

        Secrets/Variables:

        ```
        TABLE_NAME
        ```

        Example Below: 

        ```
        terraform_state_lock_table-d10
        ```

- AWS_REGION

    - Your region of choice for AWS to use when creating the Jenkins Server and Agents. 

        Secrets/Variables:

        ```
        AWS_REGION
        ```

        Example Below: 

        ```
        ap-northeast-1
        ```

- AWS_AMI

    - Your AMI to use for your EC2 based on the region selected. 

        Secrets/Variables:

        ```
        AWS_AMI
        ```

        Example Below: 

        ```
        ami-03f4fa076d2981b45
        ```

- AWS_ITYPE

    - Your itype to use for your EC2 based on your needs. 

        Secrets/Variables:

        ```
        AWS_ITYPE
        ```

        Example Below: 

        ```
        t2.micro
        ```

- AWS_KEYNAME

    - Your keyname to use for your EC2 based on your SSH Keys generated on AWS. Must be already generated. Must be already generated and contain no spaces or dots. 

        Secrets/Variables:

        ```
        AWS_KEYNAME
        ```

        Example Below: 

        ```
        Tokyo
        ```

- AWS_SECGROUPNAME

    - Your secgroupname to use for your EC2 based on your security groups Created on AWS. Must be already generated and contain no spaces or dots. 

        Secrets/Variables:

        ```
        AWS_SECGROUPNAME
        ```

        Example Below: 

        ```
        Jenkins
        ```

- DOCKERHUB_USR

    - Your username to login to DockerHub. Cannot contain spaces or dots. 

        Secrets/Variables:

        ```
        DOCKERHUB_USR
        ```

        Example Below: 

        ```
        Jeff
        ```

- DOCKERHUB_PWD

    - Your password to login to DockerHub. Cannot contain spaces or dots or some punctuation characters. 

        Secrets/Variables:

        ```
        DOCKERHUB_PWD
        ```

        Example Below: 

        ```
        2WQ0vrQI
        ```

</details>

# Diagram

<details>

<summary>Show Diagram</summary>

<br>

<p align="center">
<a href="https://github.com/RichardDeodutt/Deployment-5/blob/main/Images/Diagram.drawio.png"><img src="https://github.com/RichardDeodutt/Deployment-5/blob/main/Images/Diagram.drawio.png" />
</p>

</details>

# Notes

<details>

<summary>Show Notes</summary>

- The Jenkins Server seems to become unresponsive during cypress test it might be because of not enough resources so I moved it to the Terraform Agent to do the test. 

- Containers communicate to each other using localhost and the nginx container is the link connecting it to the loadbalancer and therefore the internet. 

- The `Docker Agent` builds the Dockerfile images and pushes it to `Dockerhub`. You have to use the same [repo names](https://hub.docker.com/u/richarddeodutt) or change the files to match the names you want to use. 

- The `Terraform Agent` will `Deploy` the Docker Images to `ECS` and do the `Cypress E2E` test. 

- Port `80` on the loadbalancer is the `frontend`.

- Port `5000` on the loadbalancer is the `backend`.

- Port `9000` on the loadbalancer is the `adminer`.

- All the Github Secrets are required to function correctly. 

</details>

# Issues 

<details>

<summary>Show Issues</summary>

- Sometimes apt fails because of `broken packages` or other reason making this system `not 100% reliable`. The broken packages issue is handled as a warning and ignored. 

- Sometimes the Jenkins server plugin downloads can fail for `unknown reasons` and it times out, currently a unhandled situation. There seems to be issues with dependencies so you have to manually go to the Jenkins Server and fix them. Does `not happen frequently`. 

- Stopping a job when it's building the tools might cause issues with npm so using a time based method is `unreliable as it guesses` when it starts. Need a better method to check when it auto starts the first job and cancels it or a way to have it `not auto start a first job`. There also seems to be some sort of `memory leak` that makes it impossible to complete the build tools stage when `it was run on the Jenkins Server node` due to lack of `RAM` on a t2.micro `over time`. 

- On Adminer using `localhost` does not work and you need to use `127.0.0.1` instead for some `strange reason`. 

- Security is a `huge issue` with this setup and using `secrets` to replace the `database password` in the `public repo` and other sensitive information would greatly improve `security`. 

</details>

# Possible Improvements 

<details>

<summary>Show Possible Improvements</summary>

- With some more times I can work on the `Issues`

- Maybe I could use `Ansible` to do the configuration of Jenkins. 

- Improve the `Terraform files` to create the secuirty group and keypair and other resources it needs for the Jenkins Server. 

- Making this system less `unstable`. 

- Tidy up the code to be more `readable` espeically those `bash scripts`, they need more `functions`. 

- Right now I have one container with Nginx but I could `potentially` have more for redundancy or just have them in it's own task and have `several replicas` of it all being pointed at by the `load balancer`. 

- Improve `security`. 

</details>

# Index

<details>

<summary>Show Index</summary>

- [.github/workflows](https://github.com/RichardDeodutt/Deployment-5/tree/main/.github/workflows) the Github Actions Workflows. 

- [Configs](https://github.com/RichardDeodutt/Deployment-5/tree/main/Configs) the configuration files used in some scripts. 

- [Images](https://github.com/RichardDeodutt/Deployment-5/tree/main/Images) the images used for this repo. 

- [Modified-Application-Files](https://github.com/RichardDeodutt/Deployment-5/tree/main/Modified-Application-Files) the files modified for the fork. 

- [Runners](https://github.com/RichardDeodutt/Deployment-5/tree/main/Runners) single bash scripts that runs other bash scripts. 

- [Scripts](https://github.com/RichardDeodutt/Deployment-5/tree/main/Scripts) bash scripts that accomplish tasks. These are being unit test every build. 

- [Terraform](https://github.com/RichardDeodutt/Deployment-5/tree/main/Terraform) Holds the terraform files for the pipeline and remote statefile. 

- [Utilities](https://github.com/RichardDeodutt/Deployment-5/tree/main/Utilities) utilities such as a python script that replaces text with other text. 

</details>