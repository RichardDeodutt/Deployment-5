# Deployment-5
Set up a CI/CD pipeline from start to finish using a Jenkins server and deploying with Terraform a containerized application.

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

    - AWS SSH Key Pair to SSH into the Jenkins Server EC2 in base64 format using the base64 command. 

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

    - The name of the Build Job or Project Jenkins uses. 

        Secrets/Variables:

        ```
        JENKINS_JOB_NAME
        ```

        Example Below: 

        ```
        Deployment-4
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
        https://github.com/RichardDeodutt/Deployment-4
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

    - Your S3 bucket name for storing the Terraform statefile. 

        Secrets/Variables:

        ```
        BUCKET_NAME
        ```

        Example Below: 

        ```
        terraform-remote-statefile-store-d10
        ```

- TABLE_NAME

    - Your DynamoDB table name for storing the lockfile of the Terraform statefile. 

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

    - Your keyname to use for your EC2 based on your SSH Keys generated on AWS. Must be already generated.  

        Secrets/Variables:

        ```
        AWS_KEYNAME
        ```

        Example Below: 

        ```
        Tokyo
        ```

- AWS_SECGROUPNAME

    - Your secgroupname to use for your EC2 based on your security groups Created on AWS. Must be already generated.  

        Secrets/Variables:

        ```
        AWS_SECGROUPNAME
        ```

        Example Below: 

        ```
        Jenkins Ports
        ```

</details>