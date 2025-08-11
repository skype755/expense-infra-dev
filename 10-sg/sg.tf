module "mysql_sg" {
    source = "git::https://github.com/skype755/terraform-aws-securitygroup?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "mysql"
    sg_description = "Created for MySQL instances in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "backend_sg_new" {
  source = "git::https://github.com/skype755/terraform-aws-securitygroup.git?ref=main"
 
}

module "backend_sg" {
    source = "git::https://github.com/skype755/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "backend"
    sg_description = "Created for backend instances in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "frontend_sg" {
    source = "git::https://github.com/skype755/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "frontend"
    sg_description = "Created for frontend instances in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "bastion_sg" {
    source = "git::https://github.com/skype755/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "bastion"
    sg_description = "Created for bastion instances in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}

module "app_alb_sg" {
    source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
    project_name = var.project_name
    environment = var.environment
    sg_name = "app-alb"
    sg_description = "Created for backend ALB in expense dev"
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    common_tags = var.common_tags
}
# # vpn ports gneral 22, 443, 1194, 943
# module "vpn_sg" {
#     source = "git::https://github.com/DAWS-82S/terraform-aws-securitygroup.git?ref=main"
#     project_name = var.project_name
#     environment = var.environment
#     sg_name = "vpn"
#     sg_description = "Created for VPN instnaces in expense dev"
#     vpc_id = data.aws_ssm_parameter.vpc_id.value
#     common_tags = var.common_tags
# }

resource "aws_security_group_rule" "app_alb_bastion_http" {
  type              = "ingress"
  from_port         = 80
  to_port           = 80
  protocol          = "tcp"
 source_security_group_id = module.bastion_sg.sg_id
security_group_id = module.app_alb_sg.sg_id
}

resource "aws_security_group_rule" "bastion_public" {
  type              = "ingress"
  from_port         = 22
  to_port           = 22
  protocol          = "tcp"
 cidr_blocks = ["0.0.0.0/0"]
security_group_id = module.bastion_sg.sg_id
}

resource "aws_security_group_rule" "app_alb_bastion_https" {
  type              = "ingress"
  from_port         = 443
  to_port           = 443
  protocol          = "tcp"
 source_security_group_id = module.bastion_sg.sg_id
security_group_id = module.app_alb_sg.sg_id
}

resource "aws_security_group_rule" "mysql_bastion" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
 source_security_group_id = module.bastion_sg.sg_id 
  security_group_id = module.mysql_sg.sg_id
}

resource "aws_security_group_rule" "backend_bastion_ssh" {
  type              = "ingress"
  from_port         = 22 
  to_port           = 22
  protocol          = "tcp"
 source_security_group_id = module.bastion_sg.sg_id 
  security_group_id = module.backend_sg.sg_id
}

resource "aws_security_group_rule" "backend_bastion_http" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
  source_security_group_id = module.bastion_sg.sg_id
  security_group_id = module.backend_sg.sg_id
}

resource "aws_security_group_rule" "backend_app_alb" {
  type              = "ingress"
  from_port         = 8080
  to_port           = 8080
  protocol          = "tcp"
 source_security_group_id = module.app_alb_sg.sg_id 
  security_group_id = module.backend_sg.sg_id
}

resource "aws_security_group_rule" "mysql_backend" {
  type              = "ingress"
  from_port         = 3306
  to_port           = 3306
  protocol          = "tcp"
 source_security_group_id = module.backend_sg.sg_id 
  security_group_id = module.mysql_sg.sg_id
}

