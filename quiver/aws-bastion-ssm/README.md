<!-- 
---
type: "post"
title: "Effortless AWS Bastion Setup"
topic: "Security"
date: "2023-06-28T15:30:00-07:00"
author: "Abrham Martinez"
time: "1 min read"
description: "Discover the power of an AWS EC2 Bastion instance, a centralized and secure gateway that enhances your cloud infrastructure's security."
url: "/blog/aws-bastion-ssm"
---
-->

# **Effortless AWS Bastion Setup**

## **Description**
This Terraform provisions the infrastructure for a fully managed bastion. The bastion serves as a secure entry point to access your resources within a Virtual Private Cloud (VPC). By leveraging SSM, you can establish a secure and controlled connection to your resources without the need for a public IP or opening inbound SSH ports.

## **Use Cases**
The Terraform bastion setup can be utilized in various scenarios, including:

1. **Secure Remote Access**: Provide a secure remote access solution by allowing authorized users to connect to AWS resources through the bastion host. Users can securely manage and administer resources without directly exposing them to the public internet.

2. **Bastion Alternative**: Replace traditional bastion hosts with this setup. The bastion host acts as an intermediate access point, allowing a direct connection to resources located in private subnets based on ports.

3. **Enhanced Security**: Restrict access to resources by leveraging security groups to control inbound and outbound traffic between the bastion host and other resources. This helps protect sensitive data and ensures that only authorized communication is allowed.

## **Diagram**
![Bastion Diagram](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/main/quiver/aws-bastion-ssm/diagrams/bastion-diagram.png)

## **How It Works**

### **Requirements**
- [Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
- [AWS CLI](https://github.com/aws/aws-cli)
- [Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)

**For connection:**
- User with IAM policy ssm:StartSession
- Set document/AWS-StartPortForwardingSessionToRemoteHost on the user's policy

Steps: 
1. Run `terraform init` to install modules: This will install the necessary modules to initialize.

2. Run `terraform plan` to review changes in your actual AWS infrastructure ![terraform plan command](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/main/quiver/aws-bastion-ssm/diagrams/terraform_plan.svg)

3. Change local variables if needed
   
    Default variables: 

    ```
    locals {
        aws_region      = "us-east-2"  # Specify the AWS region where the infrastructure will be deployed
        vpc_cidr_block  = "142.32.0.0/16"  # Define the CIDR block for the VPC
        ami_id          = "ami-01107263728f3bef4"  # Specify the ID of the AMI
        instance_type   = "t2.micro"  # Specify the type of the EC2 instance
        vpc_name        = "BastionVPC" # Provide a name for the VPC
        ec2_tag_name    = "Bastion EC2" # Specify a name tag for the EC2 instance
    }
    ```

4. Run `terraform apply` to apply changes to infrastructure ![terraform apply command](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/main/quiver/aws-bastion-ssm/diagrams/terraform_apply.svg)

5. **Apply the security group to the desired resource within the same VPC to enable a connection from the bastion to the resource.**, *This Terraform code creates a security group that includes the necessary ports to establish a connection with a PostgreSQL RDS.* 

6. Apply the following IAM Policy on the AWS Console to the desired user profile in order to enable connection to the SSM:
    *Replace the instance ID with the ID of the EC2 instance with the tag name "Bastion EC2"*

    ```json
        {
            "Version": "2012-10-17",
            "Statement": [
                {
                    "Sid": "AllowSSMStartSessionEC2",
                    "Effect": "Allow",
                    "Action": "ssm:StartSession",
                    "Resource": "arn:aws:ec2:us-east-2:*:instance/<instance_id>"
                },
                {
                    "Sid": "AllowSSMUseDocument",
                    "Effect": "Allow",
                    "Action": "ssm:StartSession",
                    "Resource": "arn:aws:ssm:us-east-2:*:document/AWS-StartPortForwardingSession"
                }
            ]
        }
    ```
    *Command to obtain the bastion instance ID:*
`aws ec2 describe-instances --filters "Name=tag:Name,Values=Bastion EC2"`

## Usage
```bash
    aws ssm start-session \
        --target <instance_id> \
        --document-name AWS-StartPortForwardingSessionToRemoteHost \
        --parameters '{"host":["<resource_endpoint|resource_ip>"], "portNumber":["<host_port>"], "localPortNumber":["<machine_port>"]}'
```


instance_id: The instance id of the EC2 you want to establish a session with (e.g. i-0123456789abcdef0)

portNumber: The port number on the remote resource which you want to forward traffic. (e.g. 80)

localPortNumber: The port number you want to use locally. (e.g. 5432)

## Support
If you encounter any issues or have questions related to this AWS BASTION SSM setup with Terraform, or need assistance setting up the BASTION or any other related services, Hire us and we can do it for you.

To get started, you can visit our website [blackarrowgang.com](https://blackarrowgang.com) to explore our services and schedule a meeting with our team. We are committed to providing you with the necessary support and guidance to ensure a successful implementation of your VPN infrastructure.

Dont forget to checkout our youtube channel [Black Arrow Gang](https://www.youtube.com/@blackarrowgang3373), where we will showcase the functionality of this services in the future. 

And if you are feeling generous, you can go ahead and buy us a cup of coffee.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://blackarrowgang.com)
