data "aws_caller_identity" "caller" {}

module "vpc" {
  source               = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  name                 = "vpc-${var.name}"
  cidr                 = var.vpc_cidr
  azs                  = var.azs
  private_subnets      = var.private_subnets
  enable_dns_hostnames = true
  enable_nat_gateway   = false
}

# Route all private traffic to the TGW
resource "aws_route" "route-prod-all-to-tgw" {
  count                  = length(module.vpc.private_route_table_ids)
  route_table_id         = module.vpc.private_route_table_ids[count.index]
  transit_gateway_id     = aws_ec2_transit_gateway.tgw.id
  destination_cidr_block = "0.0.0.0/0"
}


################
# TGW
################

data "aws_ami" "amazon-2" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-ebs"]
  }
  owners = ["amazon"]
}

resource "aws_ec2_transit_gateway" "tgw" {
  description = "${var.name}-tgw"
  tags = {
    "Name" = "${var.name}-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "vpc" {
  subnet_ids         = module.vpc.private_subnets
  transit_gateway_id = aws_ec2_transit_gateway.tgw.id
  vpc_id             = module.vpc.vpc_id
  tags = {
    "Name" = "${var.name}-vpc"
  }
}

resource "aws_ec2_transit_gateway_peering_attachment" "master-peering" {
  peer_account_id         = var.master_account_id
  peer_region             = var.master_region
  peer_transit_gateway_id = var.master_tgw_id
  transit_gateway_id      = aws_ec2_transit_gateway.tgw.id
  tags = {
    "Name" = "${var.name}-tgw"
  }
}

data "aws_ec2_transit_gateway_peering_attachment" "peering-attachment" {
  provider = aws.master
  depends_on = [aws_ec2_transit_gateway_peering_attachment.master-peering]
  filter {
    name   = "transit-gateway-id"
    values = [var.master_tgw_id]
  }
  filter {
    name   = "remote-owner-id"
    values = [data.aws_caller_identity.caller.id]
  }
  filter {
    name   = "state"
    values = ["available", "pendingAcceptance"]
  }
}

resource "aws_ec2_transit_gateway_peering_attachment_accepter" "attachment-accepter" {
  provider = aws.master
  transit_gateway_attachment_id = data.aws_ec2_transit_gateway_peering_attachment.peering-attachment.id
  tags = {
    "Name" = "prod-tgw"
  }
}

resource "aws_ec2_transit_gateway_route" "to-anywhere" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway.tgw.propagation_default_route_table_id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_peering_attachment.master-peering.id
}


################
# Test instance
################
resource "aws_security_group" "app" {
  name   = "${var.name}-vpc-app-sg"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.instance_sg_allow_from_cidr
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  subnet_id              = module.vpc.private_subnets[0]
  instance_type          = "t3.micro"
  ami                    = data.aws_ami.amazon-2.id
  iam_instance_profile   = var.instance_profile_name
  vpc_security_group_ids = [aws_security_group.app.id]
  tags = {
    "Name" = "${var.name}-box"
  }
}

output "instance_private_ip" {
  value = aws_instance.app.private_ip
}

output "instance_id" {
  value = aws_instance.app.id
}

output "account_id" {
  value = data.aws_caller_identity.caller.account_id
}

output "vpc_id" {
  value = module.vpc.vpc_id
}

output "peering_attachment_id" {
  value = data.aws_ec2_transit_gateway_peering_attachment.peering-attachment.id
}
