provider "aws" {
  profile = "default"
  region  = "us-east-2"
}

module "security_group" {
  source      = "terraform-aws-modules/security-group/aws"
  name        = "vpn_access"
  description = "Allow connection to vpn"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 443
      to_port     = 443
      protocol    = "udp"
      description = "Allow connection to vpn from all ip ranges"
      cidr_blocks = "0.0.0.0/0"
    }
  ]
}

module "security_group_networks" {
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
    server_certificate_arn = "REPLACE_WITH_SERVER_ARN_CERTIFICATE"
    client_cidr_block      = "192.168.128.0/22"
    split_tunnel           = "true"
    security_group_ids     = [module.security_group.security_group_id,module.security_group-networks.security_group_id]
    vpc_id                 = module.vpc.vpc_id

    authentication_options {
        type                       = "certificate-authentication"
        #Use client-certificate ARN from AWS ACM https://docs.aws.amazon.com/vpn/latest/clientvpn-admin/mutual.html
        root_certificate_chain_arn = "REPLACE_WITH_ROOT_ARN_CERTIFICATE"
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
    name   = "custom-vpc"
    cidr   = "142.32.0.0/16"

    azs            = ["us-east-2a", "us-east-2b"]
    private_subnets = ["142.32.1.0/24", "142.32.2.0/24"]
}