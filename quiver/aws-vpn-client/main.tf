resource "aws_ec2_client_vpn_endpoint" "client-vpn" {
  description            = "Client-VPN"
  server_certificate_arn = var.server_certificate
  client_cidr_block      = var.vpn_cidr_block
  split_tunnel           = "true"
  security_group_ids     = [module.vpn_access_sg.security_group_id,module.resource_access_sg.security_group_id]
  vpc_id                 = var.vpc_id

  authentication_options {
      type                       = "certificate-authentication"
      root_certificate_chain_arn = var.client_certificate
  }

  connection_log_options {
      enabled = false
  }
}

resource "aws_ec2_client_vpn_authorization_rule" "authroize_vpn_vpc" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn.id
  target_network_cidr    = var.vpc_cidr_block
  authorize_all_groups   = true
}

resource "aws_ec2_client_vpn_network_association" "associate_subnet_1" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn.id
  subnet_id              = var.private_subnets[0]
}

resource "aws_ec2_client_vpn_network_association" "associate_subnet_2" {
  client_vpn_endpoint_id = aws_ec2_client_vpn_endpoint.client-vpn.id
  subnet_id              = var.private_subnets[1]
}

module "vpn_access_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.1.0"

  name        = "vpn_access"
  description = "Allow connection to vpn"
  vpc_id      = var.vpc_id

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

module "resource_access_sg" {
  source      = "terraform-aws-modules/security-group/aws"
  version     = "5.1.0"
  
  name        = "resource_access"
  description = "Allow access to resources inside VPC"
  vpc_id      = var.vpc_id

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