provider "aws" {
  profile = var.profile
  region  = var.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name   = "database-cluster-vpc"
  azs    = var.availability_zones

  cidr   = var.vpc_cidr_block
  private_subnets = var.private_subnets
  database_subnets = var.database_subnets
}

module "rds_proxy" {
  source  = "terraform-aws-modules/rds-proxy/aws"
  version = "2.1.2"

  name          = "rds-proxy"
  iam_role_name = "rds-proxy-role"
  iam_auth      = "DISABLED"

  create_iam_policy = true
  create_iam_role   = true
  manage_log_group  = false
  require_tls       = false

  vpc_subnet_ids         = [module.vpc.database_subnets[0], module.vpc.database_subnets[1]]
  vpc_security_group_ids = [module.rds_access_security_group.security_group_id, module.resource_access_security_group.security_group_id]

  db_proxy_endpoints = {
    read_write = {
      name                   = "read-write-endpoint"
      vpc_subnet_ids         = [module.vpc.database_subnets[0], module.vpc.database_subnets[1]]
      vpc_security_group_ids = [module.rds_access_security_group.security_group_id, module.resource_access_security_group.security_group_id]
    }
  }

  secrets = {
    "root" = {
      description = "Aurora PostgreSQL superuser password"
      arn         = aws_secretsmanager_secret.root.arn
      kms_key_id  = aws_secretsmanager_secret.root.kms_key_id
    }
  }

  engine_family         = "POSTGRESQL"
  target_db_cluster     = true
  db_cluster_identifier = module.rds_aurora.cluster_id
}

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

  availability_zones = [module.vpc.azs[0],module.vpc.azs[1]]
  instance_class = "db.serverless"
  instances = var.database_instances

  serverlessv2_scaling_configuration = var.serverless_scaling

  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.resource_access_security_group.security_group_id]

  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  monitoring_interval = 60
  skip_final_snapshot = true
  apply_immediately   = true
  storage_encrypted   = true

  tags = {
    madeby = "BlackArrowGang"
  }
}

module "vpn_access_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "vpn_access"
  description = "Allow connection to vpn"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "udp"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "rds_access_security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "rds_access"
  description = "Allow access from proxy to rds"
  vpc_id      = module.vpc.vpc_id

  ingress_with_self = [
    {
      from_port = var.resource_port
      to_port   = var.resource_port
      protocol  = 6
      self      = true
    }
  ]

  #Allow access from vpn to rds or other resource inside private subnet
  egress_with_self = [
    {
      from_port = var.resource_port
      to_port   = var.resource_port
      protocol  = 6
      self      = true
    }
  ]
}

module "resource_access_security_group" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "5.1.0"

  name        = "resource-access"
  description = "Allow access to aws resources"
  vpc_id      = module.vpc.vpc_id

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

module "kms" {
  source = "terraform-aws-modules/kms/aws"

  description = "RDS key usage"
  key_usage   = "ENCRYPT_DECRYPT"

  aliases = ["blackarrowgang/rds"]
}

resource "aws_secretsmanager_secret" "root" {
  name        = "root-0"
  description = "RDS super user credentials"
  kms_key_id  = module.kms.key_id  
}

resource "aws_secretsmanager_secret_version" "root" {
  secret_id = aws_secretsmanager_secret.root.id
  secret_string = jsonencode({
    username = "root" 
    password = "admin123"
  })
}

resource "aws_ec2_client_vpn_endpoint" "client_vpn" {
  description            = "VPN Endpoint"
  server_certificate_arn = var.server_certificate

  client_cidr_block      = var.vpn_cidr_block
  split_tunnel           = "true"
  vpc_id                 = module.vpc.vpc_id
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
  target_network_cidr    = module.vpc.vpc_cidr_block
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "subnet_0" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = module.vpc.private_subnets[0]
}

resource "aws_ec2_client_vpn_network_association" "subnet_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client_vpn.id
  subnet_id              = module.vpc.private_subnets[1]
}