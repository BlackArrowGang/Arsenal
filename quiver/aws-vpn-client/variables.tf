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

variable "availability_zones" {
    type = list
    description = "Availability zones"
}

variable "private_subnets" {
    type = list
    description = "List of subnets inside the VPC range"
}

variable "server_certificate" {
    type = string
    description = "ARN of the server certificate for the VPN"
}

variable "client_certificate" {
    type = string
    description = "ARN of the client certificate for the VPN"
}