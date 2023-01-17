# ec2-terraform-aws-module


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
    
#### 2. Update the vpc_id variable to your own VPC ID - `variables.tf`

    variable "vpc_id" {
        description = "The VPC to deploy into"
        type        = string
        default     = "ENTER HERE"
    }
    
#### 3. Update the s3 bucket name to your own - `versions.tf`

    backend "s3" {
      bucket = "ENTER HERE"
      key    = "terraform.tfstate"
      region = "eu-west-2"
    }

#### 4. Region Updates

Finally, update all area's of code which include the AWS Region to a region specific to your own needs/requirements.

#### 5.	Initialise the TF directory

    terraform init

#### 6.	 Ensure the terraform code is formatted and validated 

    terraform fmt && terraform validate

#### 7.	Create an execution plan

    terraform plan

<img width="353" alt="image" src="https://user-images.githubusercontent.com/83971386/212928533-87314b48-7da2-4979-a6ec-28aabcc3676d.png">

#### 8.	Execute terraform configuration - Creating the EC2 Infrastructure

    terraform apply --auto-approve
    
<img width="381" alt="image" src="https://user-images.githubusercontent.com/83971386/212929638-0f0c3e28-251b-4f69-a5af-27cbbe0b3a6c.png">


## Verification Steps 

#### 1. Check AWS Infrastructure
Check the infrastructure deployment status, by enter the following terraform command -

     terraform show

<img width="423" alt="image" src="https://user-images.githubusercontent.com/83971386/212930070-afa1158f-75e2-4ab9-9660-146301e72ae5.png">

Alternatively, log into the AWS Console and verify your AWS infrastructure deployment from there.

## Teardown steps

#### 1.	Destroy the deployed AWS Infrastructure 
`terraform destroy --auto-approve`

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.0 |
| <a name="requirement_aws"></a> [aws](#requirement\_aws) | >= 4.50 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_aws"></a> [aws](#provider\_aws) | >= 4.50 |

## Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_ec2"></a> [ec2](#module\_ec2) | terraform-aws-modules/ec2/aws | ~> 3.0 |

## Useful Links

* https://github.com/terraform-aws-modules/terraform-aws-ec2-instance
