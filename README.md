# aws-multi-node
Terraform enables you to safely and predictably create, change and improve 
infrastructures. This allows a blueprint of your datacenter to be versioned and 
treated as you would any other code. Additionally, infrastuctures can be shared 
and re-used. 

This project is a custom infrastructure built with 
[Terraform Language (HCL)](https://www.terraform.io/docs/language/index.html) 
to deploy an Amazon Linux 2 server to act as a 
[bastion-server](https://aws.amazon.com/quickstart/architecture/linux-bastion/),
one CSR1000v running IOS XE 17.3.3 and our newest lunch, a Catalyst 8000v 
running IOS XE 17.4.1b. Besides you will have a pool of multiple instances of 
common interest that you can customize and deploy based on your needs. 

## Prerequisites

To deploy this infrastructure you will need:
* The [Terraform CLI](https://learn.hashicorp.com/tutorials/terraform/install-cli?in=terraform/aws-get-started) (0.14.9+) installed.
* The [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) installed.
* [An AWS account](https://aws.amazon.com/free/).
* Your AWS credentials. You can [create a new Access Key on this page](https://console.aws.amazon.com/iam/home?#/security_credentials).

## Installation

1. Download a copy of the infrastructure to your local device:

```bash
git clone https://github.com/etoromol/aws-multi-node.git
cd aws-multi-node
```

2. Initialize the working directory containing Terraform configuration files:
```bash
terraform init
```

## Configuration

3. Setup the AWS CLI from your terminal. Follow the prompts to input your AWS 
Access Key ID and Secret Access Key:

```hcl
aws configure
```
*The configuration process stores your credentials in a file at ~/.aws/credentials 
on MacOS and Linux, or %UserProfile%\.aws\credentials on Windows.*

4. Go to [variable.tf](variables.tf) file and customize your project's name and 
environment arguments:

```hcl
variable "project" {
  description = "Name and Environment type of the infrastructure"
  type        = map(string)
  default = {
    "name"        = "aws_sandbox" <-
    "environment" = "d"           <-
  }
}
```  

5. Go to [variable.tf](variables.tf) file and define the access_key default 
argument with the name of your SSH key:

```hcl
var "access_key" {
  description = "Name of the SSH key selected to access the instances"
  type = string
  default = "" <-
}
```  

## Deployment

6. Once your infrastructure is ready, start with the deployment:

```bash
terraform apply
```

7. When your instance is ready, access using your ssh key:

```bash
ssh -i "path_to_your_ssh_key" ec2-user@public_ip_address_given
```

8. Destroy your infrastructure if it is no longer needed:

```bash
terraform destroy
```
*The Terraform apply and destroy plans will show to you before initialization. 
Type yes if you are good, otherwise Terraform will not proceed further.*

## License

Copyright (c) 2021 Eduardo Toro.

Licensed under the [MIT](LICENSE) license.