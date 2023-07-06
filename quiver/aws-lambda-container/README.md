<!-- 
---
type: "post"
title: "AWS Lambda Containers: A Game-Changer for Scalable and Efficient Serverless Applications"
topic: "Provisioning"
date: "2023-07-01T15:30:00-07:00"
author: "Fernando Reyes"
time: "2 min read"
description: "Simplify the deployment of Docker containers as Lambda functions on AWS using Terraform. This code snippet leverages the benefits of serverless architecture and containers to create a Lambda function module that effortlessly deploys a container image."
url: "/blog/aws-lambda-container"
---
-->

# **AWS Lambda Containers: A Game-Changer for Scalable and Efficient Serverless Applications**

🚀AWS Lambda with containers merges the advantages of serverless computing and containerization. Developers can package their applications into containers, enjoying benefits like scalability, cost-effectiveness, and simplified management. Automatic scaling and reduced operational burden empower developers to concentrate on coding and delivering exceptional solutions. 🐳⚙️

## **Table of contents**

* [Use Cases](#use-cases)
* [Requirements](#requirements)
* [Installation](#installation)
* [Usage](#usage)
* [How It Works](#how-it-works)
* [Support](#support)

![Lambda Container Diagram](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/main/quiver/aws-lambda-container/media/aws-lambda-container-diagram.png)

## **Use Cases**
1. **Serverless Microservices:** Deploy Docker containers as Lambda functions using Terraform to create serverless microservices architectures. Benefit from independent scaling and optimized resource utilization by encapsulating specific functionalities or services within each containerized Lambda function.

2. **CI/CD Pipelines:** Streamline your CI/CD pipelines by deploying Docker containers on AWS Lambda with Terraform. Automate the deployment of containerized applications as Lambda functions, ensuring consistent and reliable deployment across multiple environments like development, staging, and production.

3. **Scheduled Tasks and Cron Jobs:** Terraform enables you to schedule Docker container execution as Lambda functions, making it ideal for automating routine tasks, cron jobs, and scheduled processes. Whether it's data backups, periodic data processing, or system maintenance, you can leverage Lambda's built-in scheduling capabilities to execute containerized tasks at specific intervals.


## **Requirements**
| Name     | Version  |
|----------|----------|
|[Terraform](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli) | >= 1.0 |
|[AWS CLI](https://github.com/aws/aws-cli)  | >= 2.0 |
|[Docker](https://docs.docker.com/engine/install/)   | >= 24.0 |

## **Installation**

Clone the repository
```
git clone https://github.com/BlackArrowGang/Arsenal.git
```
Go to the solution directory
```
cd /Arsenal/quiver/aws-lambda-container
```
Install terraform modules
```
terraform init
```

## **Usage**

To use this code, follow these steps:

**Elastic Container Registry**
  1. Create a private repository
      - Refer to this <a href="https://docs.aws.amazon.com/AmazonECR/latest/userguide/repository-create.html" target="_blank">AWS documentation</a>
  2. Click on the View push commands button
      ![Private repositories page](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/main/quiver/aws-lambda-container/media/image_01.png)
  3. Push your image to the repository
      ![Push image to repo commands](https://raw.githubusercontent.com/BlackArrowGang/Arsenal/main/quiver/aws-lambda-container/media/image_02.png)

**Note:** Make sure the image you want to upload has an appropiate base image to work on a lambda function, you can search in the <a href="https://gallery.ecr.aws/" target="_blank">ECR Public Gallery</a>.

**Modify Code**
   1. Set the desired profile, region, function name and description on the locals section inside the main.tf file
   2. Add your ECR image URI.

**Terraform Setup**

Once the image is uploaded to the repository, the lambda function can be deployed.

   1. Open a terminal window.
   2. Run the following commands.

```
terraform plan
```
```
terraform apply
```

## **How It Works**

1. Local Variables
    - This section defines a set of local variables using the locals block. These variables store configuration values such as the AWS profile, region, Lambda function name, function description, and Docker image URI.

2. Provider Configuration
    - Configure the AWS provider profile and region from the local variables.

3. Lambda Configuration
    - Configures the Lambda function using the terraform aws module, and setting the name, description and image uri.

## **Support**

If you encounter any issues or need assistance setting things up, Hire us and we can do it for you. 

Want to try things for yourself?, checkout our github repository [Arsenal](https://github.com/BlackArrowGang/Arsenal/tree/main/quiver/aws-lambda-container).

To get started, you can visit our website [blackarrowgang.com](https://blackarrowgang.com) to explore our services and schedule a meeting with our team. We are committed to providing you with the necessary support and guidance.

Dont forget to checkout our youtube channel [Black Arrow Gang](https://www.youtube.com/@blackarrowgang3373), where we will showcase the functionality of this services in the future. 

And if you are feeling generous you can go ahead and buy us a cup a coffee.

[!["Buy Me A Coffee"](https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png)](https://blackarrowgang.com)
