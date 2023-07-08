variable "provider_profile" {
    type = string
}

variable "provider_region" {
    type = string
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
  type = map
  default = {
    min_capacity = 0.5
    max_capacity = 1
  }
}

variable "resource_port" {
  type    = string
}

variable "vpc_cidr_block" {
  type    = string
}

variable "vpn_cidr_block" {
  type    = string
}

variable "availability_zones" {
  type    = list(string)
}

variable "private_subnets" {
  type    = list(string)
}

variable "database_subnets" {
  type    = list(string)
}

variable "server_certificate" {
  type    = string
}

variable "client_certificate" {
  type    = string
}