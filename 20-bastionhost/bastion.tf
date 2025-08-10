resource "aws_instance" "bastion" {
  ami                    = data.aws_ami.joindevops.id
  vpc_security_group_ids = [data.aws_ssm_parameter.bastion_sg_id.value]
  
  instance_type          = "t3.micro"
  subnet_id = local.public_subnet_id
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-bastion"
    }
  )
}

# Store bastion public IP in SSM Parameter Store
resource "aws_ssm_parameter" "bastion_public_ip" {
  name  = "/bastion/public_ip"
  type  = "String"
  value = aws_instance.bastion.public_ip
}