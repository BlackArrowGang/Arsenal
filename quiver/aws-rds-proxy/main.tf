locals{
  profile = "default"
  region  = "us-east-2"

  database_name              = "database-cluster"
  database_engine            = "aurora-postgresql"
  database_engine_mode       = "provisioned"
  database_engine_version    = "14.6"

  database_user = "root"
  database_pass = "admin123"

  database_instances = {
    one = {}
    two = {}
  }

  serverless_scaling = {
    min_capacity = 0.5
    max_capacity = 1
  }

  resource_port  = "5432"
  vpc_cidr_block = "142.32.0.0/16"
  vpn_cidr_block = "192.168.128.0/22"
  
  availability_zones = ["us-east-2a", "us-east-2b"]
  private_subnets    = ["142.32.1.0/24", "142.32.2.0/24"]
  database_subnets   = ["142.32.3.0/24", "142.32.4.0/24"]

  server_certificate = "<server-cert-arn>"
  client_certificate = "<client-cert-arn>"
}

provider "aws" {
  profile = local.profile
  region  = local.region
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "5.0.0"

  name   = "database-cluster-vpc"
  azs    = local.availability_zones

  cidr   = local.vpc_cidr_block
  private_subnets = local.private_subnets
  database_subnets = local.database_subnets
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

  name              = local.database_name
  engine            = local.database_engine
  engine_mode       = local.database_engine_mode
  engine_version    = local.database_engine_version

  master_username   = local.database_user
  master_password   = local.database_pass
  manage_master_user_password = false

  availability_zones = [module.vpc.azs[0],module.vpc.azs[1]]
  instance_class = "db.serverless"
  instances = local.database_instances

  serverlessv2_scaling_configuration = local.serverless_scaling

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
      from_port = local.resource_port
      to_port   = local.resource_port
      protocol  = 6
      self      = true
    }
  ]

  #Allow access from vpn to rds or other resource inside private subnet
  egress_with_self = [
    {
      from_port = local.resource_port
      to_port   = local.resource_port
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
      from_port = local.resource_port
      to_port   = local.resource_port
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
  server_certificate_arn = local.server_certificate

  client_cidr_block      = local.vpn_cidr_block
  split_tunnel           = "true"
  vpc_id                 = module.vpc.vpc_id
  security_group_ids     = [module.vpn_access_security_group.security_group_id,module.resource_access_security_group.security_group_id]

  authentication_options {
    type                       = "certificate-authentication"
    root_certificate_chain_arn = local.client_certificate
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