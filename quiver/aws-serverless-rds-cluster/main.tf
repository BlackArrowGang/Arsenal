module "rds_aurora" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "8.3.1"

  name              = var.database_name
  engine            = var.database_engine
  engine_mode       = var.database_engine_mode
  engine_version    = var.database_engine_version

  master_username   = var.database_user
  master_password   = var.database_pass
  manage_master_user_password = false

  availability_zones = [var.availability_zones[0],var.availability_zones[1]]
  instance_class = "db.serverless"
  instances = var.database_instances

  serverlessv2_scaling_configuration = var.serverless_scaling

  vpc_id                 = var.vpc_id
  db_subnet_group_name   = var.database_subnet_group_name
  vpc_security_group_ids = [module.resource_access_security_group.security_group_id]

  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = var.private_subnets_cidr_blocks
    }
  }

  monitoring_interval = 60
  skip_final_snapshot = true
  apply_immediately   = true
  storage_encrypted   = true

  tags = {
    madeby    = "BlackArrowGang"
  }
}

module "vpn_access_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "vpn_access"
  description = "Allow connection to vpn"
  vpc_id      = var.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = var.resource_port
      to_port     = var.resource_port
      protocol    = "udp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "resource_access_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "resource-access"
  description = "Allow access to aws resources"
  vpc_id      = var.vpc_id

  #Allow access from vpn to rds or other resources inside private subnet
  ingress_with_self = [
    {
      rule = "all-all"
    }
  ]

  egress_with_self = [
    {
      from_port = var.resource_port
      to_port   = var.resource_port
      protocol  = 6
      self      = true
    }
  ]
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "VPN Endpoint"
  server_certificate_arn = var.server_certificate

  client_cidr_block      = var.vpn_cidr_block
  split_tunnel           = "true"
  vpc_id                 = var.vpc_id
  security_group_ids     = [module.vpn_access_security_group.security_group_id,module.resource_access_security_group.security_group_id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = var.client_certificate
  }

  connection_log_options {
    enabled = false
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "authroize_vpn_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "subnet_0" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.private_subnets[0]
}

resource "aws_ec2_client_vpn_network_association" "subnet_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = var.private_subnets[1]
}