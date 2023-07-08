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