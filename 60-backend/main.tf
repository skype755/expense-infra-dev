resource "aws_instance" "backend" {
  ami                    = data.aws_ami.joindevops.id # golden AMI
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id   = local.private_subnet_id
  tags = merge(
    var.common_tags,
    {
        Name = "${var.project_name}-${var.environment}-backend"
    }
  )
}

resource "null_resource" "backend" {
  triggers = {
    instance_id = aws_instance.backend.id
  }

  connection {
    type             = "ssh"
    user             = "ec2-user"
    password         = "DevOps321"
    host             = aws_instance.backend.private_ip

# we need to give bastion public ip connected from bastion host
# and user name and password for bastion ip as well
   bastion_host     = data.aws_ssm_parameter.bastion_ip.value
    bastion_user     = "ec2-user"
    bastion_password = "DevOps321"
  }

  provisioner "file" {
    source      = "backend.sh"
    destination = "/tmp/backend.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/backend.sh",
      "sudo sh /tmp/backend.sh ${var.environment}"
    ]
  }
}

resource "aws_ec2_instance_state" "backend" {
  instance_id = aws_instance.backend.id
  state       = "stopped"
}