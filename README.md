# hashicat-aws
Terraform Apps for TFE workshops

Includes "Meow World" website and Dockerfiles for building containerized apps.

## 1. Using Terraform OSS
### Clone / Initialise / Provision

    git clone https://github.com/jeromebaude/hashicat-aws.git terraform-aws-hashicat
    cd terraform-aws-hashicat

update it with your own prefix (and pay attention to EIP quota limit in your AWS region)

### Build our own AMI with Packer

    packer validate template_packer.json
    packer build -only=amazon-ebs template_packer.json
    vi main.tf (comment apache install and use packer newly built AMI)

(for vmware see https://www.packer.io/docs/builders/vmware.html)

(AWS images are https://eu-north-1.console.aws.amazon.com/ec2/home?region=eu-north-1#Images:sort=name)


### Demo runthrought

    terraform init
    terraform apply -auto-approve


Problems:

:warning: State files are decentralised
if you centralize it, it’s not easy to collaborate, who’s doing what ? 
```
cat terraform.tfstate
```    
:warning: Secrets are not securely stored
```
ls ~/.aws/credentials
```
:warning: Out of band changes are possible without tracing
```
terraform apply -var placeholder=placebear.com -var height=500 -var width=500 -auto-approve
terraform apply -var placeholder=placebeard.it -var height=500 -var width=500 -auto-approve
```


## 2. Using Terraform Enterprise (aka TFE)
### Create a workspace on app.terraform.io

    new workspace > skip this step > terraform-aws-hashicat
    general settings > local

(Create a user token, if not already done: https://app.terraform.io/app/settings/tokens vi ~/.terraformrc)

### 2.1 Enable remote_backend
    cp ./ORG/remote_backend.tf remote_backend.tf
    vi remote_backend.tf
    terraform init

Show current lock on workspace UI -> start to better collaborate but that’s not enough.

if all good

    rm terraform.tfstate*
    vi terraform.tfvars
    terraform apply -auto-approve

### 2.2 Remote exec to protect sensitive variables

Configure Remote exec (and auto-apply)

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

    terraform apply -auto-approve

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

Add a variable `enable_dns_hostnames` and set it to `false`

Deploy the infrastructure and notice the policy check error
```
terraform apply -auto-approve    
```

Change the variable and set it to `true`. It should now work

(disable the sentinel rule)

### 2.4 GitOps thru VCS integration

Version control systems allow users to store, track, test, and collaborate on changes to their infrastructure and applications.

Let's upgrade our workspace to use our Github repository https://github.com/jeromebaude/hashicat-aws.git

    Settings > Version Control > Select 1st Github > jeromebaude/hashicat-aws
    
Update VCS Settings

    vi files/deploy_app.sh
    git add files/deploy_app.sh
    git add main.tf
    git commit -m “updated text”
    git push origin master

Create a DevTestBranch and change Terraform VCS settings to connect to this branch

Edit deploy_app.sh and commit thru the GitHub web UI. This will trigger a new Terraform Run (Plan+Apply)

Open a Pull Request and see that All checks passed (click on details to see that Terraform run was successfull)

Merge the change into the main branch

(Change the VCS config to the master branch and destroy everything)

### 2.5 RBAC

Terraform Cloud's organizational and access control model is based on three units: users, teams, and organizations.
https://www.terraform.io/docs/cloud/users-teams-organizations/index.html

Go to Settings > Teams > TeamSupport and check that `jeromebaude2` belongs to the `TeamSupport` team

Login to chrome incognito window to https://app.terraform.io

    login: jeromebaude2
    password: XXX

Check that no workspace is visible

Back to main browser (login as jeromebaude):
Go to workspace `terraform-aws-hashicat` Settings > Team Access > Add a Team and give `read permissions` to `TeamSupport`

Back to chrome incognito (login as jeromebaude2) and check that we can now see workspace `terraform-aws-hashicat`
But we cannot `Queue Plan`

### 2.6 Cost Estimation

Terraform Cloud provides cost estimates for many resources found in your Terraform configuration. For each resource an hourly and monthly cost is shown, along with the monthly delta. The total cost and delta of all estimable resources is also shown.

To enable Cost Estimation for your organization, check the box in your organization's settings.

Disable `auto-apply` and add a new variable

Add the following variable
```
instance_type: m5.large
```
Discard Run "too expensive"


### 2.7 Private Module Registry

Terraform modules are reusable packages of Terraform code that you can use to build your infrastructure. Terraform Enterprise includes a Private Module Registry where you can store, version, and distribute modules to your organizations and teams.

- In your TFE organization, navigate to the modules section and add https://github.com/jeromebaude/terraform-aws-hashicat-module to your private registry.

```
cp ./ORG/main.module.tf main.tf
cp ./ORG/outputs.module.tf outputs.tf
vi main.tf
git add main.tf outputs.tf
git commit -m "demo using modules"
```


#### cleanup 

```
./clean.sh
cd ..
rm -rf terraform-aws-hashicat
```

- delete github branch DevTestBranch
- delete terraform-aws-hashicat workspace
- deactivate cost estimation on all workspaces
- remove support team workspace visibility
- remove AWS ECS Fargate Module from the private registry
