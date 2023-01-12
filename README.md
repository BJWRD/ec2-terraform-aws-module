# ec2-terraform-aws-module
The following project includes a range of AWS Services/features such as EC2 Instance, AWS Security, AWS Networking provisioned via Terraform and including the TF best practices.

# Architecture

Enter Image 

**Note:** - The following architecture doesn't reflect all the components that are created by this template. However, it does provide a high-level overview of the core infrastructure that will be created.

# Prerequisites
* An AWS Account with an IAM user capable of creating resources – `AdminstratorAccess`
* A locally configured AWS profile for the above IAM user
* Terraform installation - [steps](https://learn.hashicorp.com/tutorials/terraform/install-cli)
* AWS EC2 key pair - [steps](https://docs.aws.amazon.com/AWSEC2/latest/UserGuide/ec2-key-pairs.html)

# How to Apply/Destroy
This section details the deployment and teardown of the three-tier-architecture. **Warning: this will create AWS resources that costs money**

## Deployment steps

### Applying the Terraform Configuration

#### 1.	Clone the repo

    git clone https://github.com/BJWRD/ec2-terraform-aws-module

#### 2.	Initialise the TF directory

    terraform init

#### 3.	 Ensure the terraform code is formatted and validated 

    terraform fmt && terraform validate

#### 4.	Create an execution plan

    terraform plan

#### 5.	Execute terraform configuration - Creating the EC2 Infrastructure

    terraform apply --auto-approve
    
ENTER IMAGE

## Verification Steps 

#### 1. Check AWS Infrastructure
Check the Infrastructure status, by accessing the AWS Console and visually confirming that your resources have been created, following the `Terraform complete`

#### 2. Verify SSH access to the EC2 Instance 
Search for the EC2 Service via the AWS Console search facility 

Enter Image

Once the EC2 instance has been located, select it - - - 

To be completed

    ssh 

## Teardown steps

#### 1.	Destroy the deployed AWS Infrastructure 
`terraform destroy --auto-approve`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.47 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.47 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_eks"></a> [eks](#module\_eks) | terraform-aws-modules/ec2/aws | ~> UPDATE |

## Useful Links

* https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
