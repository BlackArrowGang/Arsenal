variable "aws_region" {
  type      = string
  default   = "us-east-2"
}

variable "aws_profile_name" {
  type      = string
  default   = "default"
}

variable "vpc_cidr_block" {
  type      = string
  default   = "142.32.0.0/16"
}

variable "vpc_name" {
  type      = string
  default   = "BastionVPC"
}

variable "ami_id" {
  type      = string
  default   = "ami-01107263728f3bef4"
}

variable "instance_type" {
  type      = string
  default   = "t2.micro"
}

variable "ec2_tag_name" {
  type      = string
  default   = "Bastion EC2"
}