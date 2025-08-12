variable "project_name" {
    default = "expense"
}

variable "environment" {
    default = "dev"
}

variable "common_tags" {
    default = {
        Project = "expense"
        Environment = "dev"
        Terraform = "true"
    }
}

variable "zone_id" {
  default = "Z06755682HLUVK97WWDXL"
}

variable "domain_name" {
  default = "dev-ops.chat"
}