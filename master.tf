module "vpc-master" {
  source               = "registry.terraform.io/terraform-aws-modules/vpc/aws"
  name                 = "vpc-master"
  cidr                 = local.master_vpc_cidr
  azs                  = ["us-east-1a", "us-east-1b"]
  public_subnets       = ["10.10.0.0/24", "10.10.1.0/24"]
  private_subnets      = ["10.10.2.0/24", "10.10.3.0/24"]
  enable_dns_hostnames = true
  enable_nat_gateway   = true
  single_nat_gateway   = true
}

# From public subnet to prod
resource "aws_route" "route-master-public-to-prod" {
  route_table_id         = module.vpc-master.public_route_table_ids[0]
  transit_gateway_id     = aws_ec2_transit_gateway.master-tgw.id
  destination_cidr_block = local.prod_vpc_cidr
}

# From public subnet to dev
resource "aws_route" "route-master-public-to-dev" {
  route_table_id         = module.vpc-master.public_route_table_ids[0]
  transit_gateway_id     = aws_ec2_transit_gateway.master-tgw.id
  destination_cidr_block = local.dev_vpc_cidr
}

# From private subnet to prod
resource "aws_route" "route-master-private-to-prod" {
  route_table_id         = module.vpc-master.private_route_table_ids[0]
  transit_gateway_id     = aws_ec2_transit_gateway.master-tgw.id
  destination_cidr_block = local.prod_vpc_cidr
}

# From private subnet to dev
resource "aws_route" "route-master-private-to-dev" {
  route_table_id         = module.vpc-master.private_route_table_ids[0]
  transit_gateway_id     = aws_ec2_transit_gateway.master-tgw.id
  destination_cidr_block = local.dev_vpc_cidr
}

resource "aws_security_group" "endpoints" {
  name   = "vpc-endpoints"
  vpc_id = module.vpc-master.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = [local.prod_vpc_cidr, local.dev_vpc_cidr]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

################
## VPC Endpoints to support SSM sessions
################
resource "aws_vpc_endpoint" "ec2-messages" {
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.aws_region}.ec2messages"
  vpc_id             = module.vpc-master.vpc_id
  subnet_ids         = module.vpc-master.private_subnets
  security_group_ids = [aws_security_group.endpoints.id]
}

resource "aws_vpc_endpoint" "ssm-messages" {
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.aws_region}.ssmmessages"
  vpc_id             = module.vpc-master.vpc_id
  subnet_ids         = module.vpc-master.private_subnets
  security_group_ids = [aws_security_group.endpoints.id]
}

resource "aws_vpc_endpoint" "ssm" {
  vpc_endpoint_type  = "Interface"
  service_name       = "com.amazonaws.${var.aws_region}.ssm"
  vpc_id             = module.vpc-master.vpc_id
  subnet_ids         = module.vpc-master.private_subnets
  security_group_ids = [aws_security_group.endpoints.id]
}

################
## Master TGW
################

resource "aws_ec2_transit_gateway" "master-tgw" {
  description                     = "master-tgw"
  amazon_side_asn                 = 65010
  default_route_table_association = "disable"
  default_route_table_propagation = "disable"
  tags = {
    "Name" = "master-tgw"
  }
}

resource "aws_ec2_transit_gateway_vpc_attachment" "master-vpc" {
  subnet_ids                                      = module.vpc-master.private_subnets
  transit_gateway_id                              = aws_ec2_transit_gateway.master-tgw.id
  vpc_id                                          = module.vpc-master.vpc_id
  transit_gateway_default_route_table_association = false
  transit_gateway_default_route_table_propagation = false
  tags = {
    "Name" = "master-vpc"
  }
}

#### Route Table for connections coming from master VPC
resource "aws_ec2_transit_gateway_route_table" "master-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.master-tgw.id
  tags = {
    "Name" = "master-rt"
  }
}

resource "aws_ec2_transit_gateway_route" "to-prod" {
  destination_cidr_block         = local.prod_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.master-rt.id
  transit_gateway_attachment_id  = module.prod.peering_attachment_id
}

resource "aws_ec2_transit_gateway_route" "to-dev" {
  destination_cidr_block         = local.dev_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.master-rt.id
  transit_gateway_attachment_id  = module.dev.peering_attachment_id
}


resource "aws_ec2_transit_gateway_route_table_association" "master-rt-assoc" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.master-vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.master-rt.id
}


#### Route Table for connections coming from prod and dev VPC
resource "aws_ec2_transit_gateway_route_table" "spoke-rt" {
  transit_gateway_id = aws_ec2_transit_gateway.master-tgw.id
  tags = {
    "Name" = "spoke-rt"
  }
}

resource "aws_ec2_transit_gateway_route_table_propagation" "spoke-rt-master-vpc-propagation" {
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.master-vpc.id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke-rt.id
}

resource "aws_ec2_transit_gateway_route" "spoke-rt-to-anywhere" {
  destination_cidr_block         = "0.0.0.0/0"
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke-rt.id
  transit_gateway_attachment_id  = aws_ec2_transit_gateway_vpc_attachment.master-vpc.id
}

resource "aws_ec2_transit_gateway_route" "spoke-rt-disable-prod-conn" {
  count                          = var.allow_infra_vpc_connection ? 0 : 1
  destination_cidr_block         = local.prod_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke-rt.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route" "spoke-rt-disable-dev-conn" {
  count                          = var.allow_infra_vpc_connection ? 0 : 1
  destination_cidr_block         = local.dev_vpc_cidr
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke-rt.id
  blackhole                      = true
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke-rt-assoc-prod" {
  transit_gateway_attachment_id  = module.prod.peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke-rt.id
}

resource "aws_ec2_transit_gateway_route_table_association" "spoke-rt-assoc-dev" {
  transit_gateway_attachment_id  = module.dev.peering_attachment_id
  transit_gateway_route_table_id = aws_ec2_transit_gateway_route_table.spoke-rt.id
}
