# Provider info
provider "aws" {
  region  = var.aws_region
  profile = var.aws_profile_name 
}

# Get default VPC
data "aws_vpc" "default" {
  default = true
}

# module "vpc" {
#   source  = "terraform-aws-modules/vpc/aws"
#   version = "5.0.0"
#   name    = var.vpc_name  
#   cidr    = var.vpc_cidr_block 
#   azs              = ["${var.aws_region}a", "${var.aws_region}b"]  # Specify the availability zones for the VPC
#   private_subnets  = [cidrsubnet(var.vpc_cidr_block, 8, 1), cidrsubnet(var.vpc_cidr_block, 8, 2)]  # Define the private subnets within the VPC
# }

# Create EC2 instance with role and security groups
module "ec2_instance" {
  source                  = "terraform-aws-modules/ec2-instance/aws"
  ami                     = var.ami_id  
  instance_type           = var.instance_type  
  tags = {
    Name                  = var.ec2_tag_name 
  }
  vpc_security_group_ids  = [
    module.security_group_bastion_rds.security_group_id,
    module.security_group_aws_internal_tools.security_group_id
  ]
  iam_instance_profile    = module.iam_assumable_role.iam_instance_profile_name
}

# Create more security group to connect multiples resources to bastion
# Create BastionRDS security group
module "security_group_bastion_rds" {
  source        = "terraform-aws-modules/security-group/aws"
  name          = "BastionRDS"  
  description   = "Two-way communication between Bastion and RDS"  
  vpc_id        = data.aws_vpc.default.id

  ingress_with_self = [
    {
      from_port = 5432
      to_port   = 5432
      protocol  = "tcp"
      self      = true
    },
  ]  # Allow inbound traffic from the security group itself on port 5432
  egress_with_self  = [
    {
      from_port = 5432
      to_port   = 5432
      protocol  = "tcp"
      self      = true
    }
  ]  # Allow outbound traffic to the security group itself on port 5432
}

# Create AWS internal tools security group
module "security_group_aws_internal_tools" {
  source        = "terraform-aws-modules/security-group/aws"
  name          = "AWS Internal Tools"  # Provide a name for the security group
  description   = "Allow connection from outside to bastion using AWS SSM"  # Describe the purpose of the security group
  vpc_id        = data.aws_vpc.default.id  # Use the VPC ID from the VPC module

  egress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "tcp"
      description = "AWS Internal Tools"
      cidr_blocks = "0.0.0.0/0"
    },
    {
      from_port   = 80
      to_port     = 80
      protocol    = "tcp"
      description = "AWS Internal Tools"
      cidr_blocks = "0.0.0.0/0"
    }
  ]  # Allow outbound traffic to port 443 and 80 to any destination
}

# Create role with SSM access
module "iam_assumable_role" {
  source                  = "terraform-aws-modules/iam/aws//modules/iam-assumable-role"
  create_role             = true
  create_instance_profile = true

  role_name              = "ec2_ssm_access"  # Specify a name for the IAM role
  role_description       = "SSM Access Role"  # Describe the purpose of the IAM role

  trusted_role_services  = ["ec2.amazonaws.com"]  # Specify the trusted services for the IAM role
  role_requires_mfa      = false  # Set whether MFA is required for the IAM role

  custom_role_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
  ]  # Attach custom IAM policies to the role for SSM access
}
