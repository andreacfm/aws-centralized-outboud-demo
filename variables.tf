variable "aws_region" {
  type = string
}

variable "allow_infra_vpc_connection" {
  type = bool
  default = true
}

variable "prod_iam_role_arn" {
  type = string
}

variable "dev_iam_role_arn" {
  type = string
}
