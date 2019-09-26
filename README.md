# hashicat-aws
Terraform Apps for TFE workshops

Includes "Meow World" website and Dockerfiles for building containerized apps.

## 1. Using Terraform OSS
### Clone / Initialise / Provision

    git clone https://github.com/jeromebaude/hashicat-aws.git terraform-aws-hashicat
    mv terraform.tfvars.example terraform.tfvars

update it with your own prefix (and pay attention to EIP quota limit in your AWS region)

### Demo runthrought

    terraform init
    terraform apply -auto-approve

Problems:
- State file decentralised
if you centralize it, it’s not easy to collaborate, who’s doing what ? 
```
cat terraform.tfstate
```    
- Secret sprawl
```
ls ~/.aws/credentials
```
- Out of band changes
```
terraform apply -var placeholder=placebear.com -var height=500 -var width=500 -auto-approve
terraform apply -var placeholder=placebeard.it -var height=500 -var width=500 -auto-approve
```
Note: check existing EIP consumption [5 max]

    aws ec2 describe-addresses --region us-east-1 --query ‘Addresses[*].PublicIp’

## 2. Using Terraform Enterprise (aka TFE)
### Create a workspace on app.terraform.io

    new workspace > skip this step > terraform-aws-hashicat
    general settings > local

### Create a user token, if not already done
    
    https://app.terraform.io/app/settings/tokens
       XXX
    vi ~/.terraformrc

### 2.1 Enable remote_backend
    cp remote_backend.tf.disabled remote_backend.tf
    vi remote_backend.tf
    terraform init

Show current lock on workspace UI -> start to better collaborate but that’s not enough.

if all good

    rm terraform.tfstate*

### 2.2 Remote exec to protect sensitive variables

Sensitive information like AWS credentials is currently exposed, let switch to remote exec to protect all of them,

    terraform-aws-hashicat > Settings > General > Remote
    terraform-aws-hashicat > variables > Envt > AWS_ACCESS_KEY_ID
        (grep aws_access ~/.aws/credentials  | awk '{print $3}' | pbcopy)
    terraform-aws-hashicat > variables > Envt > AWS_SECRET_ACCESS_KEY
        (grep aws_secret ~/.aws/credentials  | awk '{print $3}' | pbcopy)

All variables need to be stored in the app, if I execute it now it will fail, so let’s create all the required variables (API possible)

    terraform-aws-hashicat > variables > Vars > prefix [jerome]
    terraform apply -auto-approve

    terraform-aws-hashicat > variables > Vars > height [600]
    terraform-aws-hashicat > variables > Vars > width [800]
    terraform-aws-hashicat > variables > Vars > placeholder [placedog.net]

    terraform-aws-hashicat > Queue plan

Show app running with Dogs now.

All sensitive variables are now secured !! Environment is protected by TFE: cannot be destroyed

    terraform destroy

Add environment variable to be able to destroy
        
    CONFIRM_DESTROY: 1 

Destroy current deployment from TFE Web UI. 

### 2.3 Sentinel

Sentinel intercepts bad configurations before they go to production, not after.

Create a policy saying vpcs must have tags and enable dns hostnames

    Settings > Policies > aws-vpcs-must-have-tags-and-enable-dns-hostnames

Define a Policy Set applicable to `terraform-aws-hashicat`

    Settings > Policy Sets > mypolicyset
    
Assign `aws-vpcs-must-have-tags-and-enable-dns-hostnames` to `mypolicyset`

Deploy the infrastructure and notice the policy check error
```
terraform apply -auto-approve    
```

Add `enable_dns_hostnames = true` in resource "aws_vpc" and redeploy. It should now work

### 2.4 GitOps thru VCS integration

Version control systems allow users to store, track, test, and collaborate on changes to their infrastructure and applications.

Let's upgrade our workspace to use our Github repository https://github.com/jeromebaude/hashicat-aws.git

    Settings > Version Control > Select 1st Github > jeromebaude/hashicat-aws
    
Update VCS Settings

    vi files/deploy_app.sh
    git add files/deploy_app.sh
    git commit -m “updated text”
    git push origin master

Create a DevTestBranch and change Terraform VCS settings to connect to this branch

Edit deploy_app.sh and commit thru the GitHub web UI. This will trigger a new Terraform Run (Plan+Apply)

Open a Pull Request and see that All checks passed (click on details to see that Terraform run was successfull)

Merge the change into the main branch

### 2.5 Cost Estimation

Terraform Cloud provides cost estimates for many resources found in your Terraform configuration. For each resource an hourly and monthly cost is shown, along with the monthly delta. The total cost and delta of all estimable resources is also shown.

To enable Cost Estimation for your organization, check the box in your organization's settings.

Disable `auto-apply` and add a new variable
```
instance_type: m5.large
```

### 2.6 RBAC

explain roles org,workspace level

chrome incognito window to https://app.terraform.io

    login: xxx
    password: XXX
    
enable `terraform-aws-ec2` workspace `support` team read visibility
remove team to 
enable `terraform-aws-ec2` workspace `support` team plan visibility

### 2.8 PMR

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
