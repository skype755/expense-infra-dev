resource "aws_instance" "backend" {
  ami                    = data.aws_ami.joindevops.id # golden AMI
  vpc_security_group_ids = [data.aws_ssm_parameter.backend_sg_id.value]
  instance_type          = "t3.micro"
  subnet_id              = local.private_subnet_id
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
    type     = "ssh"
    user     = "ec2-user"
    password = "DevOps321"
    host     = aws_instance.backend.private_ip

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
  depends_on  = [null_resource.backend]
}

resource "aws_ami_from_instance" "backend" {
  name               = "${var.project_name}-${var.environment}-backend"
  source_instance_id = aws_instance.backend.id
  depends_on         = [aws_ec2_instance_state.backend]
}

resource "null_resource" "backend_delete" {


triggers = {
  instance_id = aws_instance.backend.id
}

  provisioner "local-exec" {
    command = "aws ec2 terminate-instances --instance-ids ${aws_instance.backend.id}"
  }
  depends_on = [aws_ami_from_instance.backend]
}

resource "aws_lb_target_group" "backend" {
  name                 = "${var.project_name}-${var.environment}-backend"
  port                 = 8080
  protocol             = "HTTP"
  vpc_id               = local.vpc_id
  deregistration_delay = 60

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    protocol            = "HTTP"
    port                = 8080
    path                = "/health"
    matcher             = "200-299"
    interval            = 10
  }
}
# aws lauch template needed for the custom AMi(IMAGE ID)
resource "aws_launch_template" "backend" {
  name                                 = "${var.project_name}-${var.environment}-backend"
  image_id                             = aws_ami_from_instance.backend.id
  instance_initiated_shutdown_behavior = "terminate"
  instance_type                        = "t3.micro"
  update_default_version               = true

  vpc_security_group_ids = [local.backend_sg_id]

  tag_specifications {
    resource_type = "instance"

    tags = {
      Name = "${var.project_name}-${var.environment}-backend"
    }
  }
}
# auto scaling gorup ASG
resource "aws_autoscaling_group" "backend" {
  name                      = "${var.project_name}-${var.environment}-backend"
  max_size                  = 1
  min_size                  = 1
  health_check_grace_period = 60 # 3 minutes for instance to intialise
  health_check_type         = "ELB"
  desired_capacity          = 1

  # we need to give ASG wich target we need to lauch 
  target_group_arns = [aws_lb_target_group.backend.arn]
  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
  vpc_zone_identifier = local.private_subnet_ids
  instance_refresh {
    strategy = "Rolling"
    preferences {
      min_healthy_percentage = 50
    }
    triggers = ["launch_template"]
  }

  tag {
    key                 = "Name"
    value               = "${var.project_name}-${var.environment}-backend"
    propagate_at_launch = true
  }

  timeouts {
    delete = "5m"
  }

  tag {
    key                 = "Project"
    value               = "expense"
    propagate_at_launch = false
  }

  tag {
    key                 = "Environment"
    value               = "dev"
    propagate_at_launch = false
  }
}

# # auto scaling group policy
# resource "aws_autoscaling_policy" "backend" {
#   name                   = "${local.resource_name}-backend"
#   policy_type            = "TargetTrackingScaling"
#   autoscaling_group_name = aws_autoscaling_group.backend.name
#   target_tracking_configuration {
#     predefined_metric_specification {
#       predefined_metric_type = "ASGAverageCPUUtilization"
#     }

#     target_value = 70.0
#   }
# }


#listerner rule configuration
resource "aws_lb_listener_rule" "backend" {
  listener_arn = data.aws_ssm_parameter.app_alb_listener_arn.value
  priority     = 10

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.backend.arn
  }

  condition {
    host_header {
      values = ["backend.app-${var.environment}.${var.domain_name}"] # "backend.app-dev.dev-ops.chat"
    }
  }
}