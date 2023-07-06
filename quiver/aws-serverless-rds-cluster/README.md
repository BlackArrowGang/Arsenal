<!-- 
---
type: "post"
title: "Scalable Database Cluster: AWS Aurora Serverless"
topic: "Provisioning"
date: "2023-06-26T15:30:00-07:00"
author: "Fernando Reyes"
time: "2 min read"
description: "Learn how to set up a scalable and secure serverless database cluster on AWS using Terraform. Automate the configuration process and enjoy the benefits of Aurora's performance and reliability while maintaining control over access and security."
url: "/blog/aws-serverless-rds-cluster"
---
-->

# **Scalable Database Cluster: AWS Aurora Serverless**

Discover how Terraform, a powerful infrastructure-as-code tool, simplifies the process of deploying infrastructure on AWS. This blog post provides a concise overview of using Terraform to provision an AWS Serverless database cluster, and secure VPN access. 

![RDS Cluster Diagram](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/fe605097ab64a4dd36d090593ee8f42eb55f64bc/quiver/aws-rds-cluster/diagrams/aws-serverless-rds-cluster-diagram.png)

## **Use Cases**
The AWS RDS Aurora database cluster setup can be utilized in various scenarios, including:

1.  **Effortless Scalability for Startups**: Startups effortlessly scale their databases with RDS Aurora serverless architecture and Terraform. Automatic scaling handles unpredictable growth, while streamlined resource management and cost-effective scaling optimize operations. Terraform simplifies disaster recovery, provisioning and configuration, enabling startups to establish reliable, scalable infrastructure for hassle-free growth.

2. **Highly Available Applications**: Deploying an RDS Aurora database cluster ensures high availability for your applications. By leveraging automatic replication and failover capabilities, you can maintain uninterrupted access to your database even in the event of a failure.

3. **Multi-Region Data Replication**: RDS Aurora supports cross-region replication, enabling you to replicate your database across multiple AWS regions. This provides disaster recovery capabilities and allows you to serve your customers from different geographical locations with low latency.


## **How It Works**

1. VPC Module:
    - The VPC module creates a custom VPC with the CIDR block "142.32.0.0/16" across two availability zones ("us-east-2a" and "us-east-2b").
    - It sets up two private subnets with CIDR blocks "142.32.1.0/24" and "142.32.2.0/24".
    - Additionally, it creates database subnets with CIDR blocks "142.32.3.0/24" and "142.32.4.0/24".

2. Aurora PostgreSQL RDS Module:

    - The RDS module deploys an Aurora PostgreSQL database cluster within the VPC.
    - It utilizes the "db.serverless" instance class with two instances.
    - Serverless scaling is configured with a minimum capacity of 0.5 and a maximum capacity of 1.
    - The database is connected to the VPC, a database subnet group, and the "resource_access_security_group" security group.
    - Other configurations include monitoring, skipping the final snapshot, applying changes immediately, and encrypting the storage.

3. Security Group Modules:

    - The "vpn_access_security_group" module is responsible for creating a security group named "vpn_access" that allows connection to the VPN.
    - The "resource_access_security_group" module creates a security group named "resource-access" that allows access to AWS resources.
    - The "resource_access_security_group" module enables communication between networks within the VPC and allows outbound TCP traffic on port 5432 to itself.

4. Client VPN Endpoint Configuration:

    - The server certificate ARN.
    - A client CIDR block of "192.168.128.0/22".
    - The VPN endpoint is associated with the VPC and the "vpn_access_security_group" and "resource_access_security_group" security groups.
    - Certificate-based authentication is configured with the root certificate chain ARN.

5. Client VPN Authorization Rule:
    - An authorization rule is set up to allow VPN access to the entire VPC or a specific CIDR block.
    - The authorization rule is associated with the client VPN endpoint.

6. Client VPN Network Associations:
    - The client VPN endpoint is associated with the private subnets the VPC to enable VPN connectivity.

## **Support**
If you encounter any issues or need assistance setting things up, Hire us and we can do it for you. 

Want to try things for yourself?, checkout our github repository [Arsenal](https://github.com/BlackArrowGang/Arsenal/tree/dev/quiver/aws-serverless-rds-cluster).

To get started, you can visit our website [blackarrowgang.com](https://blackarrowgang.com) to explore our services and schedule a meeting with our team. We are committed to providing you with the necessary support and guidance.

Dont forget to checkout our youtube channel [Black Arrow Gang](https://www.youtube.com/@blackarrowgang3373), where we will showcase the functionality of this services in the future. 

And if you are feeling generous you can go ahead and buy us a cup a coffee.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://blackarrowgang.com)
