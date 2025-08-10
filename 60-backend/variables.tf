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


# variable "bastion_public_ip" {
#   description = "Public IP of bastion host"
#   type        = string
# }
