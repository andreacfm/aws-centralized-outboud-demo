module "prod_instance_profile" {
  providers = {
    aws = aws.prod
  }
  source = "./modules/iam"
}

module "prod" {
  providers = {
    aws        = aws.prod
    aws.master = aws.master
  }
  source                      = "./modules/spoke_account"
  azs                         = ["us-east-1a", "us-east-1b"]
  private_subnets             = ["172.19.2.0/24", "172.19.3.0/24"]
  vpc_cidr                    = local.prod_vpc_cidr
  instance_profile_name       = module.prod_instance_profile.name
  master_tgw_id               = aws_ec2_transit_gateway.master-tgw.id
  name                        = "prod"
  master_region               = var.aws_region
  instance_sg_allow_from_cidr = [local.prod_vpc_cidr, local.dev_vpc_cidr]
  master_account_id           = data.aws_caller_identity.master.account_id
}

output "prod_instance_id" {
  value = module.prod.instance_id
}

output "prod_instance_ip" {
  value = module.prod.instance_private_ip
}