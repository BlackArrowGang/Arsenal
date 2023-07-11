variable "profile" {
    type = string
    default = "default"
}

variable "region" {
    type = string
    default = "us-east-2"
}

variable "database_name" {
    type    = string
}

variable "database_engine" {
    type    = string
}

variable "database_engine_mode" {
    type    = string
}

variable "database_engine_version" {
    type    = string
}

variable "database_user" {
    type    = string
}

variable "database_pass" {
    type    = string
}

variable "database_instances" {
    type    = map
}

variable "serverless_scaling" {
    type    = map
}

variable "availability_zones" {
    type = list
    description = "Availability zones"
}

variable "private_subnets" {
    type = list
    description = "List of subnets inside the VPC range"
}

variable "database_subnets" {
    type    = list(string)
}

variable "server_certificate" {
    type = string
    description = "ARN of the server certificate for the VPN"
}

variable "client_certificate" {
    type = string
    description = "ARN of the client certificate for the VPN"
}

variable "resource_port" {
    type = number
    description = "Resource port to access from VPN"
}

variable "vpc_id" {
    type = string
    description = "VPC id"
}

variable "vpc_cidr_block" {
    type = string
    description = "CIDR block for VPC"
}

variable "vpn_cidr_block" {
    type = string
    description = "CIDR block for VPN"
}

variable "database_subnet_group_name" {
    type = string
}

variable "private_subnets_cidr_blocks" {
    type = list
}

# Obligatory Values 

#   profile = "default"
#   region  = "us-east-2"

#   database_name              = "database-cluster"
#   database_engine            = "aurora-postgresql"
#   database_engine_mode       = "provisioned"
#   database_engine_version    = "14.6"

#   database_user = "root"
#   database_pass = "admin123"

#   database_instances = {
#     one = {}
#     two = {}
#   }

#   serverless_scaling = {
#     min_capacity = 0.5
#     max_capacity = 1
#   }

#   resource_port  = "5432"
#   vpc_cidr_block = "142.32.0.0/16"
#   vpn_cidr_block = "192.168.128.0/22"
  
#   availability_zones = ["us-east-2a", "us-east-2b"]
#   private_subnets    = ["142.32.1.0/24", "142.32.2.0/24"]
#   database_subnets   = ["142.32.3.0/24", "142.32.4.0/24"]

#   server_certificate = "<server-cert-arn>"
#   client_certificate = "<client-cert-arn>"