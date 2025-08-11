locals {
    private_subnet_id = split(",", data.aws_ssm_parameter.private_subnet_ids.value)[0]
    private_subnet_ids = split(",", data.aws_ssm_parameter.private_subnet_ids.value)
    vpc_id = data.aws_ssm_parameter.vpc_id.value
    backend_sg_id = data.aws_ssm_parameter.backend_sg_id.value
}