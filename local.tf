locals {
  master_vpc_cidr = "10.10.0.0/16"
  dev_vpc_cidr = "172.18.0.0/16"
  prod_vpc_cidr = "172.19.0.0/16"
}

data "aws_caller_identity" "master" {}