<!-- 
---
type: "post"
title: "Simplify Remote Access: Effective AWS Client VPN Endpoint Setup"
topic: "Security"
date: "2023-06-28T15:30:00-07:00"
author: "Fernando Reyes"
time: "1 min read"
description: "Discover how to effortlessly establish secure network connectivity and access resources within your AWS Virtual Private Cloud (VPC) using Terraform."
url: "/blog/aws-vpn-client"
---
-->

# **Simplify Remote Access: Effective AWS Client VPN Endpoint Setup**

AWS Client VPN Endpoint is a powerful solution that enables seamless and secure connectivity between remote users and AWS resources. With easy management and configuration, it provides a user-friendly experience for accessing sensitive data and applications.

## **Table of contents**

* [Use Cases](#use-cases)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [How It Works](#how-it-works)
* [Support](#support)

![VPN Diagram](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/dev/quiver/aws-vpn-client/diagrams/vpn-diagram.png)

## **Use Cases**
The AWS VPN setup can be utilized in various scenarios, including:

1. **Remote Access (Bastion Alternative)**: Provide a secure alternative to a bastion by enabling authorized users to securely connect with high availability to AWS resources through a virtual private network (VPN) from remote locations.

2. **Site-to-Site Connectivity**: Establish secure connections between multiple on-premises data centers or branch offices and the AWS cloud, enabling seamless and protected communication between these environments, including multi-region deployments.

3. **Third-Party Vendor Access**: Many enterprises work with external vendors or consultants who require access to specific resources for collaboration or system integration. Cloud network security plays a vital role in this scenario. This VPN can provide a secure and controlled connection for these vendors to access the necessary resources without exposing the internal network to external threats.

## **Requirements**
| Name     | Version  |
|----------|----------|
|[terraform](#requirement) | >= 1.0 |
|[aws-cli](#requirement)   | >= 2.0 |
|[openvpn](#requirement)   | >= 2.5 |

## **Installation**
Install a OpenVPN client
   - Desktop version
      - <a href="https://aws.amazon.com/vpn/client-vpn-download/" target="_blank">AWS Desktop client</a>
   - linux (Debian)
      ```
      sudo apt install openvpn
      ```

Clone the repository
```
git clone https://github.com/BlackArrowGang/Arsenal.git
```
Go to the solution directory
```
cd /Arsenal/quiver/aws-vpn-client
```
Install terraform modules
```
terraform init
```

## **Usage**

To use this code, follow these steps:

**Modify Code**
   1. Set the desired region, ports, cidr blocks, availability zones and subnets on the locals section inside the main.tf file
   2. Add your server and client certificate ARN's.

**Terraform Setup**
   1. Open a terminal window.
   2. Run the following commands.

```
terraform plan
```
```
terraform apply
```
**Connect to VPN**

   - Desktop Client
      1. Refer to this <a href="https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/mutual.html" target="_blank">AWS</a>
   documentation for detailed instructions on setting up the vpn certificates on your account.
      2. Then go to the section named "Exporting and configuring the VPN client configuration file" of this other <a href="https://aws.amazon.com/blogs/database/accessing-an-amazon-rds-instance-remotely-using-aws-client-vpn/" target="_blank">AWS</a> documentation to connect with your vpn client.
   - Linux Command
      ```
      sudo openvpn --config config.ovpn
      ```
  
## **How It Works**
1. Local Variables:
   - The code defines several local variables, including the AWS profile, region, resource port, VPC CIDR block, VPN CIDR block, availability zones, private subnets, server certificate, and client certificate.

2. Provider Configuration
   - The code specifies the AWS provider configuration using the local profile and region variables.

3. Client VPN Configuration:
   - The aws_ec2_client_vpn_endpoint resource creates the client VPN endpoint. It sets the description, server certificate ARN, client CIDR block, split tunneling, security group IDs, and VPC ID. It also configures certificate-based authentication and disables connection logging.

   - The aws_ec2_client_vpn_authorization_rule resource sets up an authorization rule for the client VPN endpoint. It authorizes all client VPN groups to access the VPC's target network CIDR block defined in the VPC module.

   - The aws_ec2_client_vpn_network_association resources associate the client VPN endpoint with the specified private subnets from the VPC module, allowing VPN clients to access resources in those subnets.

4. Security Group Modules:
   - The code includes two security group modules: "vpn_access_sg" and "resource_access_sg." The "vpn_access_sg" module allows UDP traffic on port 443 from all IP ranges, while the "resource_access_sg" module allows all inbound and outbound traffic on the specified resource port within the VPC.

5. VPC Module:
   - The code uses the "vpc" module to create a custom VPC. It sets up the VPC with the specified name, CIDR block, availability zones, and private subnets. The VPC module creates the VPC, subnets, route tables, and other associated resources.

## **Support**
If you encounter any issues or have questions related to this AWS VPN setup with Terraform, or need assistance setting up the VPN or any other related services, Hire us and we can do it for you. 

To get started, you can visit our website [blackarrowgang.com](https://blackarrowgang.com) to explore our services and schedule a meeting with our team. We are committed to providing you with the necessary support and guidance to ensure a successful implementation of your VPN infrastructure.

Dont forget to checkout our youtube channel [Black Arrow Gang](https://www.youtube.com/@blackarrowgang3373), where we will showcase the functionality of this services in the future. 

And if you are feeling generous you can go ahead and buy us a cup a coffee.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://blackarrowgang.com)