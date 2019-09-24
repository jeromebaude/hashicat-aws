# hashicat-aws
Terraform Apps for TFE workshops

Includes "Meow World" website and Dockerfiles for building containerized apps.

## 1. Using Terraform OSS
### clone / initialise / provisiom

    git clone https://github.com/jeromebaude/hashicat-aws.git terraform-aws-hashicat
    mv terraform.tfvars.example terraform.tfvars

update it with your own prefix (and pay attention to EIP quota limit in your AWS region)

### Demo runthrought

    terraform init
    terraform apply -auto-approve

Problems:
- state file decentralised
    - cat terraform.tfstate)
    - if you centralize it, it’s not easy to collaborate, who’s doing what ?

- Secret sprawl (env | grep AWS)
    
- out of band changes

    terraform apply -var placeholder=placebear.com -var height=500 -var width=500 -auto-approve
    terraform apply -var placeholder=placebeard.it -var height=500 -var width=500 -auto-approve

Note: check existing EIP consumption [5 max]

    aws ec2 describe-addresses --region us-east-1 --query ‘Addresses[*].PublicIp’

## 2. Using Terraform Enterprise (aka TFE)
### Create a workspace on app.terraform.io

    new workspace > skip this step > terraform-aws-hashicat
    general settings > local

# create a user token, if not already done
    
    https://app.terraform.io/app/settings/tokens
       XXX
    vi ~/.terraformrc
    cp remote_backend.tf.disabled remote_backend.tf
    vi remote_backend.tf

check org, workspace

# local exec, remote storage

    terraform init

then make sure created workspace is set to local]

    terraform apply

Show current lock on workspace UI -> start to better collaborate but that’s not enough.

if all good

    rm terraform.tfstate*

# remote exec to protect sensitive variables

Problem is sensitive information like AWS credentials is currently exposed, let switch to remote exec to protect all of them,

    echo “AWS_ACCESS_KEY_ID” $AWS_ACCESS_KEY_ID
    echo “AWS_SECRET_ACCESS_KEY” $AWS_SECRET_ACCESS_KEY

    terraform-aws-hashicat > Settings > General > Remote
    terraform-aws-hashicat > variables > Envt > AWS_ACCESS_KEY_ID
    terraform-aws-hashicat > variables > Envt > AWS_SECRET_ACCESS_KEY

All variables need to be stored in the app, if I execute it now it will fail, so let’s create all the required variables (API possible)

    terraform-aws-hashicat > variables > Vars > prefix [sebastien]
    terraform-aws-hashicat > variables > Vars > region [eu-west-3]

    terraform apply -auto-approve

    terraform-aws-hashicat > variables > Vars > height [600]
    terraform-aws-hashicat > variables > Vars > width [800]
    terraform-aws-hashicat > variables > Vars > placeholder [placedog.net]

    terraform-aws-hashicat > Queue plan

Show app running with Dogs now.

All sensitive variable are now secured !! nobody can steal any of it.

And envt protected by TFE, can’t destroy

    terraform destroy

# Sentinel

Add environment variable
        
        CONFIRM_DESTROY: 1 

destroy current deployment from TFE Web UI. While destroying Show Sentinel policy and explain.

    Settings > Policies > aws_enforce_tags

Assign `terraform-aws-hashicat` workspace to Policy Set

    Settings > Policy Sets > aws

# VCS

    Settings > Version Control > Select 1st Github > planetrobbie/hashicat-aws
    
    Connect to VCS

    “terraform init” [optional ?]
    vi files/deploy_app.sh
    git add files/deploy_app.sh
    git commit -m “updated text”
    git push origin master

Explain same workflow using pull requests [collaboration]

# Collab

    https://github.com/planetrobbie/hashicat-aws/blob/master/files/deploy_app.sh
    
use the pencil, edit and create a pull request.
explain checks
merge, show plan.

# Cost Estimation

    check instance_type: t2.micro
    queue plan `terraform-aws-ec2`
    update instance_type: m5.large
    queue plan again
    discard run
    queue destroy

# RBAC

explain roles org,workspace level

chrome incognito window to https://app.terraform.io

    login: xxx
    password: XXX
    
enable `terraform-aws-ec2` workspace `support` team read visibility
remove team to 
enable `terraform-aws-ec2` workspace `support` team plan visibility

# PMR

    queue plan `terraform-aws-arcade`

# cleanup 
    
    rm remote_backend.tf
    terraform init
    remove workspace `terraform-aws-hashicat` from policy set `aws`
    delete terraform-aws-hashicat` workspace
    queue destroy `terraform-aws-ec2`
    deactivate cost estimation on all workspaces.
    remove support team workspace visibility

# requirement on labtop / or use windows desktop

- Terraform
- Vault
- aws cli
- AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY
