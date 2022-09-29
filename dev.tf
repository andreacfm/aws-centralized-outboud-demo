module "dev_instance_profile" {
  providers = {
    aws = aws.dev
  }
  source = "./modules/iam"
}

module "dev" {
  providers = {
    aws = aws.dev
    aws.master = aws.master
  }
  source                      = "./modules/spoke_account"
  azs                         = ["us-east-1a", "us-east-1b"]
  private_subnets             = ["172.18.2.0/24", "172.18.3.0/24"]
  vpc_cidr                    = local.dev_vpc_cidr
  instance_profile_name       = module.dev_instance_profile.name
  master_tgw_id               = aws_ec2_transit_gateway.master-tgw.id
  name                        = "dev"
  master_region               = var.aws_region
  instance_sg_allow_from_cidr = [local.prod_vpc_cidr, local.dev_vpc_cidr]
  master_account_id           = data.aws_caller_identity.master.account_id
}

output "dev_instance_id" {
  value = module.dev.instance_id
}

output "dev_instance_ip" {
  value = module.dev.instance_private_ip
}