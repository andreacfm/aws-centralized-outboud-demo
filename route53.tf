resource "aws_route53_zone" "ssm-message" {
  name = "ssmmessages.${var.aws_region}.amazonaws.com"
  vpc {
    vpc_id = module.vpc-master.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "ssm-message" {
  name    = "ssmmessages.${var.aws_region}.amazonaws.com"
  type    = "A"
  zone_id = aws_route53_zone.ssm-message.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_vpc_endpoint.ssm-messages.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.ssm-messages.dns_entry[0].hosted_zone_id
  }
}

resource "aws_route53_vpc_association_authorization" "ssm-message-prod-assoc-auth" {
  vpc_id  = module.prod.vpc_id
  zone_id = aws_route53_zone.ssm-message.id
}

resource "aws_route53_zone_association" "ssm-message-prod-assoc" {
  provider = aws.prod
  vpc_id   = aws_route53_vpc_association_authorization.ssm-message-prod-assoc-auth.vpc_id
  zone_id  = aws_route53_vpc_association_authorization.ssm-message-prod-assoc-auth.zone_id
}

resource "aws_route53_vpc_association_authorization" "ssm-message-dev-assoc-auth" {
  vpc_id  = module.dev.vpc_id
  zone_id = aws_route53_zone.ssm-message.id
}

resource "aws_route53_zone_association" "ssm-message-dev-assoc" {
  provider = aws.dev
  vpc_id   = aws_route53_vpc_association_authorization.ssm-message-dev-assoc-auth.vpc_id
  zone_id  = aws_route53_vpc_association_authorization.ssm-message-dev-assoc-auth.zone_id
}


resource "aws_route53_zone" "ec2-message" {
  name = "ec2messages.${var.aws_region}.amazonaws.com"
  vpc {
    vpc_id = module.vpc-master.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "ec2-message" {
  name    = "ec2messages.${var.aws_region}.amazonaws.com"
  type    = "A"
  zone_id = aws_route53_zone.ec2-message.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_vpc_endpoint.ec2-messages.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.ec2-messages.dns_entry[0].hosted_zone_id
  }
}

resource "aws_route53_vpc_association_authorization" "ec2-message-prod-assoc-auth" {
  vpc_id  = module.prod.vpc_id
  zone_id = aws_route53_zone.ec2-message.id
}

resource "aws_route53_zone_association" "ec2-message-prod-assoc" {
  provider = aws.prod
  vpc_id   = aws_route53_vpc_association_authorization.ec2-message-prod-assoc-auth.vpc_id
  zone_id  = aws_route53_vpc_association_authorization.ec2-message-prod-assoc-auth.zone_id
}

resource "aws_route53_vpc_association_authorization" "ec2-message-dev-assoc-auth" {
  vpc_id  = module.dev.vpc_id
  zone_id = aws_route53_zone.ec2-message.id
}

resource "aws_route53_zone_association" "ec2-message-dev-assoc" {
  provider = aws.dev
  vpc_id   = aws_route53_vpc_association_authorization.ec2-message-dev-assoc-auth.vpc_id
  zone_id  = aws_route53_vpc_association_authorization.ec2-message-dev-assoc-auth.zone_id
}

resource "aws_route53_zone" "ssm" {
  name = "ssm.${var.aws_region}.amazonaws.com"
  vpc {
    vpc_id = module.vpc-master.vpc_id
  }
  lifecycle {
    ignore_changes = [vpc]
  }
}

resource "aws_route53_record" "ssm" {
  name    = "ssm.${var.aws_region}.amazonaws.com"
  type    = "A"
  zone_id = aws_route53_zone.ssm.zone_id

  alias {
    evaluate_target_health = false
    name                   = aws_vpc_endpoint.ssm.dns_entry[0].dns_name
    zone_id                = aws_vpc_endpoint.ssm.dns_entry[0].hosted_zone_id
  }
}

resource "aws_route53_vpc_association_authorization" "ssm-prod-assoc-auth" {
  vpc_id  = module.prod.vpc_id
  zone_id = aws_route53_zone.ssm.id
}

resource "aws_route53_zone_association" "ssm-prod-assoc" {
  provider = aws.prod
  vpc_id   = aws_route53_vpc_association_authorization.ssm-prod-assoc-auth.vpc_id
  zone_id  = aws_route53_vpc_association_authorization.ssm-prod-assoc-auth.zone_id
}

resource "aws_route53_vpc_association_authorization" "ssm-dev-assoc-auth" {
  vpc_id  = module.dev.vpc_id
  zone_id = aws_route53_zone.ssm.id
}

resource "aws_route53_zone_association" "ssm-dev-assoc" {
  provider = aws.dev
  vpc_id   = aws_route53_vpc_association_authorization.ssm-dev-assoc-auth.vpc_id
  zone_id  = aws_route53_vpc_association_authorization.ssm-dev-assoc-auth.zone_id
}