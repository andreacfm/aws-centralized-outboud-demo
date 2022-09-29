variable "vpc_cidr" {
  type = string
}

variable "name" {
  type = string
}

variable "azs" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "master_region" {
  type = string
  default = "us-east-1"
}

variable "master_tgw_id" {
  type = string
}

variable "master_account_id" {
  type = string
}

variable "instance_profile_name" {
  type = string
}

variable "instance_sg_allow_from_cidr" {
  type = list(string)
}
