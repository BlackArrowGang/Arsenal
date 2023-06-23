provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

# sudo openvpn --config ./config.ovpn --log openvpn.log --writepid openvpn.pid
module "aurora_postgresql_v2" {
  source = "terraform-aws-modules/rds-aurora/aws"

  name              = "aurora-postgresql-serverlessv2"
  engine            = "aurora-postgresql"
  engine_mode       = "provisioned"
  engine_version    = "14.6"
  storage_encrypted = true
  master_username   = "root"
  master_password   = "admin123"
  manage_master_user_password = false

  vpc_id                 = module.vpc.vpc_id
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  vpc_security_group_ids = [module.security_group-networks.security_group_id]

  security_group_rules = {
    vpc_ingress = {
      cidr_blocks = module.vpc.private_subnets_cidr_blocks
    }
  }

  monitoring_interval = 60

  apply_immediately   = true
  skip_final_snapshot = true

  serverlessv2_scaling_configuration = {
    min_capacity = 0.5
    max_capacity = 1
  }

  instance_class = "db.serverless"
  instances = {
    one = {}
  }

  tags = {
    Example    = "example-tag"
    GithubRepo = "terraform-aws-rds-aurora"
    GithubOrg  = "terraform-aws-modules"
  }
}

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "vpn_access"
  description = "Some"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "udp"
      description = "Allow connection to vpn"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "security_group-networks" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "access_networks"
  description = "Allow access between networks"
  vpc_id      = module.vpc.vpc_id

ingress_with_self = [
    {
      rule = "all-all"
    }
  ]
  #Allow access from vpn to rds or other resource inside private subnet
egress_with_self = [
    {
      from_port = 5432
      to_port   = 5432
      protocol  = 6
      self      = true
    }
  ]
}

#Allow access from the vpn to a certain cidr Block inside the vpc or all the vpc
resource "aws_ec2_client_vpn_authorization_rule" "authroize_vpn_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn.id
  target_network_cidr    = module.vpc.vpc_cidr_block
  authorize_all_groups   = true
}


resource "aws_ec2_client_vpn_endpoint" "client-vpn" {
  description            = "Client-VPN"
  #Use server-certificate ARN from AWS ACM https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/mutual.html
  server_certificate_arn = "arn:aws:acm:us-east-2:401745644029:certificate/532116a7-0425-4cac-9d13-b5c3e33e2246"
  client_cidr_block      = "192.168.128.0/22"
  split_tunnel           = "true"
  security_group_ids     = [module.security_group.security_group_id,module.security_group-networks.security_group_id]
  vpc_id                 = module.vpc.vpc_id

  authentication_options {
    type                       = "certificate-authentication"
    #Use client-certificate ARN from AWS ACM https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/mutual.html
    root_certificate_chain_arn = "arn:aws:acm:us-east-2:401745644029:certificate/ba35a750-f127-4ef2-b5ea-00fb558d4a0c"
  }

  connection_log_options {
    enabled = false
  }
}

resource "aws_ec2_client_vpn_network_association" "associate_subnet_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn.id
  subnet_id              = module.vpc.private_subnets[0]

}

resource "aws_ec2_client_vpn_network_association" "associate_subnet_2" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn.id
  subnet_id              = module.vpc.private_subnets[1]

}

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"
  name   = "myrdsvpn"
  cidr   = "142.32.0.0/16"

  azs            = ["us-east-2a", "us-east-2b"]
  private_subnets = ["142.32.1.0/24", "142.32.2.0/24"]
  database_subnets = ["142.32.3.0/24", "142.32.4.0/24"]
}


# module "cluster" {
#   source  = "terraform-aws-modules/rds-aurora/aws"

#   name           = "test-aurora-db-postgres96"
#   engine         = "aurora-postgresql"
#   engine_version = "14.6"
#   instance_class = "db.r5.large"
#   instances = {
#     one = {
#       publicly_accessible = true
#     }
#     two = {
#       publicly_accessible = true
#     }
#   }

#   vpc_id               = module.vpc.vpc_id
#   db_subnet_group_name = "db-subnet-group"
#   security_group_rules = {
#     ex1_ingress = {
#       cidr_blocks = ["10.20.0.0/20"]
#     }
#     ex1_ingress = {
#       source_security_group_id = "sg-12345678"
#     }
#   }

#   storage_encrypted   = true
#   apply_immediately   = true
#   monitoring_interval = 10

#   tags = {
#     Environment = "dev"
#     Terraform   = "true"
#   }
# }

# module "vpc" {
#   source = "terraform-aws-modules/vpc/aws"
#   name   = "rds-vpc"
#   cidr   = "142.32.0.0/16"

#   azs            = ["us-east-2a", "us-east-2b"]
#   database_subnets = ["142.32.3.0/24", "142.32.4.0/24"]
# }