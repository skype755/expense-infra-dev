module "vpc" {
  #source       = "../terraform-aws-vpc"
  source = "git::https://github.com/skype755/terraform-aws-vpc.git?ref=main"

  project_name = var.project_name
  environment  = var.environment
  vpc_cidr     = var.vpc_cidr
  common_tags  = var.common_tags
  public_subnet_cidrs = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  database_subnet_cidrs = var.database_subnet_cidrs
  is_peering_required = true
}

#this can be included in module
resource "aws_db_subnet_group" "expense" {
  name       = "${var.project_name}-${var.environment}"
  subnet_ids = module.vpc.database_subnet_ids

  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}"
    }
  )
}